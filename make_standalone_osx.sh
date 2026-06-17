#!/bin/bash
#
# make_standalone_osx.sh — build a self-contained ~/Desktop/Decent.app from the
# CURRENT de1plus working tree, so John can run his in-development de1app as a
# real macOS .app.
#
# Unlike misc/makede1.tcl (which symlinks to the curated sync dir and ships only
# the distribution manifest), this copies the WHOLE working ./de1plus, including
# the macOS Bluetooth driver (ble/), and Developer-ID-signs the BLE helper so its
# TCC Bluetooth grant is stable across paths/rebuilds.
#
# LOCATION NOTE: this script and its launcher source (decent_launcher.c) live in
# misc/ and MUST stay git-tracked. nightly_build.sh runs `git -C misc clean -xdf`,
# which deletes any UNTRACKED file in misc/ — tracked files survive, untracked ones
# (e.g. a freshly-added decent_launcher.c) get wiped. So always commit them.
#
# CROSS-PLATFORM: builds on macOS (Darwin) AND on a Linux server. The output is
# always a macOS .app, so on Linux two macOS-specific things change:
#   * codesign does not exist → BLE-helper (re)signing is skipped; we rely on the
#     Developer-ID signature already committed in ble/bin/ble_helper, which rsync
#     carries over verbatim. (To re-sign, run on a Mac, or sign afterwards.)
#   * the bundled interpreter must be a *macOS* undroidwish, so PATH auto-detect is
#     disabled on Linux — you MUST pass DECENT_WISH=<path to a macOS undroidwish>.
#
# Usage:
#   /d/admin/code/de1app/make_standalone_osx.sh
# Env overrides:
#   DECENT_WISH=<path>   interpreter to bundle (e.g. undroidwish-arm64 for arm64 builds)
#                        REQUIRED on Linux (must point at a macOS undroidwish binary)
#   BLE_SIGN_ID=<id>     codesign identity for the BLE helper (macOS only)
#   APP_OUT=<path>       output .app path (default ~/Desktop/Decent.app)
#
set -euo pipefail

OS="$(uname -s)"   # Darwin (macOS) or Linux

REPO="/d/admin/code/de1app"
SRC="$REPO/de1plus"
SKEL="$REPO/misc/desktop_app/osx/Decent.app"
APP="${APP_OUT:-$HOME/Desktop/Decent.app}"
RES="$APP/Contents/Resources/de1plus"
LAUNCHER_SRC="$REPO/misc/decent_launcher.c"
SIGN_ID="${BLE_SIGN_ID:-Developer ID Application: Vid Tadel (XLS3XF57J8)}"

[ -d "$SRC" ]  || { echo "ERROR: source tree not found: $SRC"  >&2; exit 1; }
[ -d "$SKEL" ] || { echo "ERROR: app skeleton not found: $SKEL" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 1. Interpreter — the SAME undroidwish unde1plus.sh uses. The skeleton ships an
#    OLDER wish that does not boot current de1plus (writes a 0-byte log), so we
#    deliberately bundle the live one resolved from PATH instead.
# ---------------------------------------------------------------------------
if [ -n "${DECENT_WISH:-}" ]; then
    WISH="$DECENT_WISH"
elif [ "$OS" = "Linux" ]; then
    # PATH 'undroidwish' on Linux is the LINUX binary, which cannot run inside a
    # macOS .app. Force the caller to hand us a macOS interpreter explicitly.
    echo "ERROR: on Linux you must set DECENT_WISH=<path to a macOS undroidwish binary>." >&2
    echo "       (PATH auto-detect is disabled here because it would pick the Linux build.)" >&2
    exit 1
else
    RAW="$(command -v undroidwish)" || { echo "ERROR: 'undroidwish' not on PATH (set DECENT_WISH=...)" >&2; exit 1; }
    # resolve symlinks (readlink -f on modern macOS; perl abs_path as a fallback)
    WISH="$(readlink -f "$RAW" 2>/dev/null || perl -MCwd -le 'print Cwd::abs_path(shift)' "$RAW")"
fi
[ -x "$WISH" ] || { echo "ERROR: interpreter not found/executable: $WISH" >&2; exit 1; }
echo "Interpreter : $WISH"
echo "Output app  : $APP"

# ---------------------------------------------------------------------------
# 2. Bundle scaffold from the skeleton (Info.plist / icons / helper scripts) —
#    but NOT its stale wish, and NOT its symlinked de1plus (real one below).
#    --delete prunes stale skeleton files; the excludes protect our payload.
# ---------------------------------------------------------------------------
echo "Copying app skeleton ..."
rsync -a --delete \
    --exclude 'Contents/Resources/de1plus' \
    --exclude 'Contents/MacOS/wish' \
    "$SKEL/" "$APP/"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# ---------------------------------------------------------------------------
# 2b. Main executable — a compiled Mach-O launcher, NOT the skeleton's
#     #!/bin/bash 'undroidwish' script. macOS 26 enforces a LAUNCH CONSTRAINT on
#     /bin/bash and refuses to spawn it as an app's CFBundleExecutable (the app
#     fails to open: "(null)" / error 162 / -54), no matter how it is signed.
#     A real Mach-O main executable sidesteps the constraint.
#
#     The launcher execs the EXTERNAL interpreter resolved above (path written to
#     Contents/Resources/interp); we do NOT bundle a copy of it — macOS 26 also
#     refuses to re-host an already-notarized binary (undroidwish-arm64) inside
#     another bundle. So the .app depends on that interpreter being installed
#     (same as unde1plus.sh / unde1plus-arm64.sh).
# ---------------------------------------------------------------------------
printf '%s\n' "$WISH" > "$APP/Contents/Resources/interp"
if [ "$OS" = "Darwin" ]; then
    [ -f "$LAUNCHER_SRC" ] || { echo "ERROR: launcher source not found: $LAUNCHER_SRC" >&2; exit 1; }
    echo "Compiling Mach-O launcher ..."
    clang -arch arm64 -O2 -o "$APP/Contents/MacOS/Decent" "$LAUNCHER_SRC"
    rm -f "$APP/Contents/MacOS/undroidwish"   # drop the old /bin/bash launcher
    /usr/libexec/PlistBuddy -c "Set :CFBundleExecutable Decent" "$APP/Contents/Info.plist"
else
    # Can't produce a macOS Mach-O on Linux. Leave the skeleton's bash launcher in
    # place; the bundle will NOT launch on macOS 26 until the launcher is compiled
    # + signed on a Mac (re-run this script there).
    echo "WARNING: $OS can't compile the macOS launcher — bundle will NOT launch on macOS 26." >&2
    echo "         Re-run on a Mac to produce Contents/MacOS/Decent." >&2
fi

# ---------------------------------------------------------------------------
# 3. Payload — the whole working de1plus minus bloat. Keep live history/, skins,
#    plugins, and ble/.  -L materialises any symlinked content.
# ---------------------------------------------------------------------------
echo "Syncing de1plus payload (this is the slow part) ..."
mkdir -p "$RES"
rsync -aL --delete \
    --exclude '/history2'  --exclude '/history3'  --exclude '/historybk' \
    --exclude '/history_v2' --exclude '/history_v2b' --exclude '/history_fake' \
    --exclude '/history_archive' --exclude '/history_bk' \
    --exclude '/apk' --exclude '/tmp' --exclude '/builds' \
    --exclude 'CVS' --exclude '.git' --exclude '.gitignore' \
    --exclude 'log.txt' --exclude 'log.txt.*' \
    "$SRC/" "$RES/"

# ---------------------------------------------------------------------------
# 4. Bluetooth — make sure the helper is Developer-ID signed (stable TCC identity).
#    The committed helper is already signed and rsync -a preserves it; we only
#    re-sign if that is somehow not the case, so a normal build needs no network.
# ---------------------------------------------------------------------------
HELPER="$RES/ble/bin/ble_helper.bin"
if [ -f "$HELPER" ]; then
    chmod +x "$HELPER"
    if [ "$OS" != "Darwin" ]; then
        # No codesign on Linux. The committed helper is already Developer-ID
        # signed and rsync -a preserved that signature, so the bundle is usable
        # as-is. We just can't (re)sign or verify here.
        echo "ble_helper : codesign unavailable on $OS — keeping the committed Developer-ID signature (carried over by rsync)."
    elif codesign -dvv "$HELPER" 2>&1 | grep -q "Authority=Developer ID Application: Vid Tadel" \
       && codesign --verify --strict "$HELPER" 2>/dev/null; then
        echo "ble_helper : already Developer-ID signed and valid — kept."
    else
        SIGN_ID="${BLE_SIGN_ID:-Developer ID Application: Vid Tadel (XLS3XF57J8)}"
        # PLAIN Developer ID, NO hardened runtime (--options runtime): under
        # hardened runtime the helper SIGABRT-crashes on the first-time Bluetooth
        # grant instead of presenting the prompt (see ble/build.sh). The host app
        # can't be notarized anyway, so hardened runtime buys nothing.
        echo "ble_helper : re-signing (plain Developer ID) with '$SIGN_ID' ..."
        codesign --force --timestamp \
            --sign "$SIGN_ID" --identifier com.decentespresso.ble-helper "$HELPER"
        codesign --verify --strict "$HELPER" && echo "ble_helper : signature OK"
    fi
else
    echo "WARNING: $HELPER is missing — Bluetooth will NOT work in this build!" >&2
fi

# ---------------------------------------------------------------------------
# 5. Sign the launcher + native dylib + helper scripts, then seal the whole
#    bundle (Developer ID). macOS 26 won't launch an app bundling executable code
#    unless it carries a valid, consistent signature (unsigned/ad-hoc/mixed =
#    error -54). No notarization needed: a locally-built, non-quarantined app
#    launches with a plain Developer-ID signature once it is consistent.
#    ble_helper keeps its own (non-hardened) Developer-ID signature from step 4.
# ---------------------------------------------------------------------------
if [ "$OS" = "Darwin" ]; then
    echo "Signing launcher + bundle (Developer ID) ..."
    DYLIB="$RES/ble/lib/libtclble.dylib"
    [ -f "$DYLIB" ] && codesign --force --timestamp --sign "$SIGN_ID" "$DYLIB"
    # secondary helper scripts in MacOS/ (not the main exec) so --verify --deep passes
    for s in "$APP/Contents/MacOS/"*; do
        case "$s" in */Decent) continue ;; esac
        [ -f "$s" ] && codesign --force --timestamp --sign "$SIGN_ID" "$s"
    done
    codesign --force --options runtime --timestamp --sign "$SIGN_ID" "$APP/Contents/MacOS/Decent"
    codesign --force --options runtime --timestamp --sign "$SIGN_ID" "$APP"
    codesign --verify --deep --strict "$APP" && echo "bundle  : Developer-ID signed + verified"
fi

echo ""
echo "Done: $APP"
echo "First launch needs a one-time Bluetooth approval"
echo "  (a prompt, or System Settings -> Privacy & Security -> Bluetooth -> add Decent.app)."
echo "Requires the interpreter it execs to be installed: $WISH"
echo "Headless BLE check:"
echo "  '$WISH' '$RES/de1plus.tcl' --ble-test -sdlheight 801 -sdlwidth 1280 -name BLETEST"
echo "  then read: $RES/log.txt   (lines tagged BLETEST)"

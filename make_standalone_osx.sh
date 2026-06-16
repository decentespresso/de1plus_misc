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
# LOCATION NOTE: this lives at the de1app repo ROOT on purpose. nightly_build.sh
# runs `git -C misc clean -xdf`, which deletes untracked files in misc/ — that is
# what wiped the previous copy. Keep it out of misc/ (here), or git-track+push it.
#
# Usage:
#   /d/admin/code/de1app/make_standalone_osx.sh
# Env overrides:
#   DECENT_WISH=<path>   interpreter to bundle (e.g. undroidwish-arm64 for arm64 builds)
#   BLE_SIGN_ID=<id>     codesign identity for the BLE helper
#
set -euo pipefail

REPO="/d/admin/code/de1app"
SRC="$REPO/de1plus"
SKEL="$REPO/misc/desktop_app/osx/Decent.app"
APP="$HOME/Desktop/Decent.app"
RES="$APP/Contents/Resources/de1plus"

[ -d "$SRC" ]  || { echo "ERROR: source tree not found: $SRC"  >&2; exit 1; }
[ -d "$SKEL" ] || { echo "ERROR: app skeleton not found: $SKEL" >&2; exit 1; }

# ---------------------------------------------------------------------------
# 1. Interpreter — the SAME undroidwish unde1plus.sh uses. The skeleton ships an
#    OLDER wish that does not boot current de1plus (writes a 0-byte log), so we
#    deliberately bundle the live one resolved from PATH instead.
# ---------------------------------------------------------------------------
if [ -n "${DECENT_WISH:-}" ]; then
    WISH="$DECENT_WISH"
else
    RAW="$(command -v undroidwish)" || { echo "ERROR: 'undroidwish' not on PATH (set DECENT_WISH=...)" >&2; exit 1; }
    # resolve symlinks (readlink -f on modern macOS; perl abs_path as a fallback)
    WISH="$(readlink -f "$RAW" 2>/dev/null || perl -MCwd -le 'print Cwd::abs_path(shift)' "$RAW")"
fi
[ -x "$WISH" ] || { echo "ERROR: interpreter not found/executable: $WISH" >&2; exit 1; }
echo "Interpreter : $WISH"
echo "Output app  : $APP"

# ---------------------------------------------------------------------------
# 2. Bundle scaffold from the skeleton (launchers / Info.plist / icons) — but NOT
#    its stale wish, and NOT its symlinked de1plus (we lay down a real one below).
#    --delete prunes stale skeleton files; the two excludes protect our payload.
# ---------------------------------------------------------------------------
echo "Copying app skeleton ..."
rsync -a --delete \
    --exclude 'Contents/Resources/de1plus' \
    --exclude 'Contents/MacOS/wish' \
    "$SKEL/" "$APP/"

mkdir -p "$APP/Contents/MacOS"
cp "$WISH" "$APP/Contents/MacOS/wish"
chmod +x "$APP/Contents/MacOS/wish"

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
HELPER="$RES/ble/bin/ble_helper"
if [ -f "$HELPER" ]; then
    chmod +x "$HELPER"
    if codesign -dvv "$HELPER" 2>&1 | grep -q "Authority=Developer ID Application: Vid Tadel" \
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

echo ""
echo "Done: $APP"
echo "First launch needs a one-time Bluetooth approval"
echo "  (a prompt, or System Settings -> Privacy & Security -> Bluetooth -> add Decent.app)."
echo "Headless BLE check:"
echo "  '$APP/Contents/MacOS/wish' '$RES/de1plus.tcl' --ble-test -sdlheight 801 -sdlwidth 1280 -name BLETEST"
echo "  then read: $RES/log.txt   (lines tagged BLETEST)"

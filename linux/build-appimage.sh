#!/bin/bash
# build-appimage.sh ARCH UWBIN OUT
#   ARCH   aarch64 | x86_64   (must match a runtime-<ARCH> file)
#   UWBIN  path to the undroidwish binary for that arch
#   OUT    output .AppImage path
#
# Assembles a type-2 AppImage by hand: mksquashfs the AppDir, then prepend the
# matching type2 runtime. This is arch-agnostic packaging -- no ARCH binary is
# executed -- so an aarch64 host can build the x86_64 AppImage too.
set -eu
ARCH="$1"; UWBIN="$2"; OUT="$3"
BUILD="$HOME/appimage-build"
APPDIR="$BUILD/Decent-$ARCH.AppDir"
RUNTIME="$BUILD/runtime-$ARCH"
# Payload source: the misc.tcl-manifest-filtered tree by default (allowlist,
# matches APK/IPA/DMG). Override with DE1_SRC for a different tree.
PAYSRC="${DE1_SRC:-$BUILD/src-manifest}"

[ -f "$RUNTIME" ] || { echo "missing $RUNTIME" >&2; exit 1; }
[ -x "$UWBIN" ]   || { echo "missing undroidwish binary $UWBIN" >&2; exit 1; }

rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/share/decent"

install -m755 "$BUILD/AppRun"          "$APPDIR/AppRun"
install -m644 "$BUILD/decent.desktop"  "$APPDIR/decent.desktop"
install -m644 "$PAYSRC/de1_icon_v2.png" "$APPDIR/decent.png"
# .DirIcon at the AppDir root is the icon file managers show for the .AppImage
# FILE itself (the type-2 runtime + AppImage thumbnailers read it). Without it
# the file shows a generic executable icon.
install -m644 "$PAYSRC/de1_icon_v2.png" "$APPDIR/.DirIcon"
install -m755 "$UWBIN"                 "$APPDIR/usr/share/decent/undroidwish"

# Copy the app tree; drop any local run cruft so the payload is pristine.
cp -a "$PAYSRC" "$APPDIR/usr/share/decent/src"
rm -f "$APPDIR/usr/share/decent/src/log.txt" \
      "$APPDIR/usr/share/decent/src/crashcatch.tcl" \
      "$APPDIR/usr/share/decent/src/de1_exit.log" 2>/dev/null || true

# AppStream/desktop-integration convention: also expose icon + .desktop under usr/share.
mkdir -p "$APPDIR/usr/share/applications" "$APPDIR/usr/share/icons/hicolor/96x96/apps"
cp "$APPDIR/decent.desktop" "$APPDIR/usr/share/applications/decent.desktop"
cp "$APPDIR/decent.png"     "$APPDIR/usr/share/icons/hicolor/96x96/apps/decent.png"

echo "mksquashfs..."
rm -f "$BUILD/$ARCH.squashfs"
mksquashfs "$APPDIR" "$BUILD/$ARCH.squashfs" -root-owned -noappend -no-progress -quiet

echo "assembling AppImage (runtime + squashfs)..."
cat "$RUNTIME" "$BUILD/$ARCH.squashfs" > "$OUT"
chmod +x "$OUT"
echo "BUILT: $OUT  ($(du -h "$OUT" | cut -f1), $(stat -c%s "$OUT") bytes)"

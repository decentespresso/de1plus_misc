#!/bin/bash
#
# build_osx_dmgs.sh -- build the standalone OSX Decent disk images into
# de1plus/builds/ : Decent.dmg (x86_64) and Decent-arm64.dmg (Apple Silicon).
#
# Each DMG contains a self-contained Decent app (built by make_standalone_osx.sh
# from the current de1plus working tree, with the BLE library bundled) plus an
# /Applications symlink for drag-to-install.
#
# NOT notarized: undroidwish carries an appended VFS, so `codesign` can't sign
# the interpreter (it fails strict validation) and Apple's notary service would
# reject the bundle.  The DMGs are therefore unsigned -- the same way the
# official Decent OSX app ships -- so first launch needs right-click -> Open
# (or removing the quarantine attribute) to get past Gatekeeper.  The bundled
# ble_helper IS Developer-ID signed (done by make_standalone_osx.sh) so its
# Bluetooth grant is stable.
#
# Usage:  misc/build_osx_dmgs.sh            # both arches
#         BUILD_ONLY=x86  misc/build_osx_dmgs.sh
#         BUILD_ONLY=arm64 misc/build_osx_dmgs.sh
#
set -euo pipefail

MISC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILDER="$MISC/make_standalone_osx.sh"
BUILDS="$(cd "$MISC/../de1plus" && pwd)/builds"

[ -x "$BUILDER" ] || { echo "ERROR: missing $BUILDER"; exit 1; }
mkdir -p "$BUILDS"

# Keep build artifacts out of git (DMGs are ~1GB each).
[ -f "$BUILDS/.gitignore" ] || printf '*\n!.gitignore\n' > "$BUILDS/.gitignore"

resolve() { readlink -f "$(command -v "$1" 2>/dev/null)" 2>/dev/null; }

build_one() {
    local appname="$1" dmgname="$2" interp="$3" volname="$4"
    echo
    echo "############################################################"
    echo "#  Building $dmgname   ($appname)"
    echo "#  interpreter: $interp"
    echo "############################################################"
    [ -x "$interp" ] || { echo "ERROR: interpreter not found/executable: $interp"; return 1; }

    local stage; stage="$(mktemp -d)"
    mkdir -p "$stage/root"
    # Build the self-contained app (with bundled, Dev-ID-signed BLE helper).
    DECENT_WISH="$interp" "$BUILDER" "$stage/root/$appname"
    # Drag-to-install layout.
    ln -s /Applications "$stage/root/Applications"

    rm -f "$BUILDS/$dmgname"
    echo "Creating $dmgname (compressing -- this takes a minute) ..."
    hdiutil create -volname "$volname" -srcfolder "$stage/root" \
        -fs HFS+ -format UDZO -ov "$BUILDS/$dmgname" >/dev/null
    rm -rf "$stage"
    echo "==> $BUILDS/$dmgname  ($(du -h "$BUILDS/$dmgname" | cut -f1))"
}

ONLY="${BUILD_ONLY:-both}"

if [ "$ONLY" = "x86" ] || [ "$ONLY" = "both" ]; then
    X86="$(resolve undroidwish)"
    build_one "Decent.app" "Decent.dmg" "$X86" "Decent"
fi

if [ "$ONLY" = "arm64" ] || [ "$ONLY" = "both" ]; then
    ARM="$(resolve undroidwish-arm64)"
    build_one "Decent-arm64.app" "Decent-arm64.dmg" "$ARM" "Decent arm64"
fi

echo
echo "Done.  Builds in: $BUILDS"
ls -lh "$BUILDS"/*.dmg 2>/dev/null

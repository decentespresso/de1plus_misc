#!/bin/bash
# Complete "push de1app source to the iPad".
#
# de1app on iOS reads code from TWO places:
#   - the app bundle (cwd)         -> top-level *.tcl (gui/utils/vars/dui/...)
#   - ~/Documents/Decent ([homedir]) -> skins, plugins, profile_editors, translation*
# So a real sync must update BOTH. This does that, then reinstalls + relaunches.
set -uo pipefail

# de1app source = the de1plus of the decentespresso/de1app repo this `misc`
# submodule is embedded in (misc/ios -> ../../de1plus). No duplicate copy: the
# iOS app bundles a build-time rsync of THIS tree, nothing is forked.
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../de1plus" && pwd)"
DIST=/Users/john/iwish/dist
APP="$DIST/IwishDE1dev.app"
B="$APP/de1plus"
DEV=F8B770E6-60A9-5FCE-9266-D63B7BFB0840
ID=com.decent.de1app
CERT=6C05310364D9264A80165D6594CB5CD1E7D6CFB8
PROFILE="$DIST/de1app.mobileprovision"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IWISH="$HERE/iwish"                       # the johnbuckman/iwish submodule (runtime + shared scripts)
SIGN="$IWISH/scripts/sign-and-install-device.sh"   # generic signer: <app> <id> <profile> <udid> [ent]
ENT="$HERE/de1app.entitlements"

# skins that are seeded into Decent (only these exist on-device)
SEEDED_SKINS=(default Insight "Insight Dark" Streamline "Streamline Dark" \
              DSx DSx2 MimojaCafe Metric MiniMetric)

dpush() { # $1 = path relative to de1plus -> push to Decent
    if xcrun devicectl device copy to --device "$DEV" --domain-type appDataContainer \
         --domain-identifier "$ID" --source "$SRC/$1" --destination "Documents/Decent/$1" >/dev/null 2>&1
    then echo "  Decent <- $1"; else echo "  FAIL    $1"; fi
}

echo "1) bundle: rsync all .tcl (the cwd-read top-level code)"
/usr/bin/rsync -a --include='*/' --include='*.tcl' --exclude='*' "$SRC/" "$B/"
echo "   bundle tcl files: $(find "$B" -name '*.tcl' | wc -l | tr -d ' ')"

echo "1b) runtime: ensure the pure-Tcl Unix commands are present (iwish runtime file)"
# unix-commands.tcl is an iWish-runtime file (ls/cat/cp/...; iOS has no exec). A
# clean iwish runtime already ships it in lib/tcl8.6 with init.tcl hooked; this
# self-heals a bundle built before that. Source of truth = the iwish submodule.
UC="$IWISH/scripts/unix-commands.tcl"
TL="$APP/lib/tcl8.6"
if [ -f "$UC" ]; then
    cp "$UC" "$TL/unix-commands.tcl" && echo "   lib/tcl8.6/unix-commands.tcl"
    if /usr/bin/grep -q "unix-commands.tcl" "$TL/init.tcl"; then
        echo "   init.tcl already hooked"
    else
        printf '\n# iWish: pure-Tcl Unix-style commands (ls/cat/cp/... -- iOS has no exec)\ncatch {source [file join $tcl_library unix-commands.tcl]}\n' >> "$TL/init.tcl"
        echo "   init.tcl hook appended"
    fi
else
    echo "   WARN: $UC not found -- Unix commands will be missing"
fi

echo "2) reinstall the bundle"
xcrun devicectl device process terminate --device "$DEV" "$ID" >/dev/null 2>&1 || true
xattr -cr "$APP"
bash "$SIGN" "$APP" "$CERT" "$PROFILE" "$DEV" "$ENT" 2>&1 \
    | grep -iE "INSTALLED|FAILED|install failed" | head -1

echo "3) Decent: the [homedir]-read code"
dpush plugins            # whole dir (complete in source)
dpush profile_editors    # whole dir
for f in translation.tcl translation3.tcl; do [ -f "$SRC/$f" ] && dpush "$f"; done
# skin .tcl only, per seeded skin (don't clobber the seeded images)
for sk in "${SEEDED_SKINS[@]}"; do
    [ -d "$SRC/skins/$sk" ] || continue
    while IFS= read -r f; do dpush "${f#$SRC/}"; done < <(find "$SRC/skins/$sk" -name '*.tcl')
done

echo "4) relaunch"
xcrun devicectl device process launch --device "$DEV" --terminate-existing "$ID" 2>&1 | tail -1
echo "done."

#!/bin/bash
# Sign the staged de1app device bundle and install it on a connected iPad.
# PREREQS you must provide (needs your Apple Developer account):
#   1. An iPad connected & paired (xcrun devicectl list devices).
#   2. A provisioning profile (.mobileprovision) for an App ID that matches
#      Info.plist CFBundleIdentifier (com.decent.de1app), including this iPad's
#      UDID. Easiest: open Xcode -> new iOS App project with that bundle id,
#      target the iPad, enable "Automatically manage signing" with your team ->
#      Xcode creates the cert+profile; grab the generated .mobileprovision (the
#      DerivedData app's embedded.mobileprovision is the matching one).
#
# Usage: sign-and-install-device.sh <identity> <profile.mobileprovision> <ipad-udid>
#   <identity> e.g. "Apple Development: You (TEAMID)"  or  "Apple Distribution: Vid Tadel (XLS3XF57J8)"
set -uo pipefail
IDENTITY="${1:?identity}"; PROFILE="${2:?profile.mobileprovision}"; UDID="${3:?ipad udid}"
ROOT=/Users/john/iwish
APP="$ROOT/dist/IwishDE1dev.app"
# entitlements live beside this script (committed); must match the profile's App ID
ENT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/de1app.entitlements"

cp "$PROFILE" "$APP/embedded.mobileprovision"
echo "=== sign every nested dylib/.so inside-out ==="
find "$APP" \( -name "*.dylib" -o -name "*.so" \) -print0 | while IFS= read -r -d '' f; do
  codesign -f -s "$IDENTITY" --timestamp=none "$f" || echo "FAILED: $f"
done
echo "=== sign the executable + app with entitlements ==="
codesign -f -s "$IDENTITY" --timestamp=none "$APP/IwishDE1dev"
codesign -f -s "$IDENTITY" --timestamp=none --entitlements "$ENT" "$APP"
echo "=== verify ==="
codesign -dv "$APP" 2>&1 | head -5
echo "=== install on iPad $UDID ==="
xcrun devicectl device install app --device "$UDID" "$APP" && echo "INSTALLED" || echo "install failed"
echo "Then launch from the iPad home screen. Logs: the app's Documents/de1_launch.log"
echo "(read via: xcrun devicectl device copy from --device $UDID --source Documents/de1_launch.log --domain-type appDataContainer --domain-identifier com.decentespresso.iwishde1 --destination /tmp/)"

#!/bin/sh
# Rebuild libs/ble.jar from ble/src after mods/08-ble-scan-securityexception.patch.
# libs/ble.jar is a prebuilt jar in the androwish tree; patching the .java alone
# changes nothing in the APK. Run from the androwish build tree root.
set -e
: "${JAVA_HOME:=/Applications/Android Studio.app/Contents/jbr/Contents/Home}"
: "${ANDROID_HOME:=$HOME/Library/Android/sdk}"
OUT="$(mktemp -d)"
"$JAVA_HOME/bin/javac" --release 8 -nowarn \
    -cp "$ANDROID_HOME/platforms/android-35/android.jar" \
    -d "$OUT" ble/src/tk/tcl/wish/BLEClient.java
( cd "$OUT" && zip -q -X -r ble.jar tk )
cp "$OUT/ble.jar" libs/ble.jar
rm -rf "$OUT"
unzip -l libs/ble.jar | grep -q 'BLEClient.class' && echo "libs/ble.jar rebuilt"

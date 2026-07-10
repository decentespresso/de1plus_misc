#!/bin/sh
# Prune the AndroWish "batteries" (assets/<pkg> Tcl packages) down to only the
# ones the Decent de1app actually `package require`s. Run from the androwish
# build tree root AFTER checking out f73cb8be + applying the overlay. Removes
# ~1,795 files (~24 MB uncompressed). The keep-list was derived by mapping every
# de1app `package require` to its providing dir (see misc/android/BUILD.md).
set -e
KEEP="app tcl8.6 sdl2tk8.6 tcllib1.21 tcllibc1.21 blt2.4 bwidget1.9 TclCurl7.22.0 \
ble1.0 tkimg1.4 tksvg0.14 tkpath0.3.3 tls1.6 wibble0.4 zint2.13 sqlite3 mqtt2.0 \
mqtt3.1 borg1.0"
keep_re="^($(echo $KEEP | tr ' ' '|' | tr -s '|'))$"
removed=0
for d in assets/*/; do
    n=$(basename "$d")
    echo "$n" | grep -qE "$keep_re" || { rm -rf "$d"; removed=$((removed+1)); }
done
echo "pruned $removed unused Tcl-package dirs; kept: $KEEP"

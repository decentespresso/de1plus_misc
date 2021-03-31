#!/bin/bash

../misc/makede1.tcl

# back up settings
adb pull /mnt/sdcard/de1plus/settings.tdb /tmp/settings.tdb

adb shell rm -rf /mnt/sdcard/de1plus
adb push /d/download/sync/de1nightly/* /mnt/sdcard/de1plus

adb pull /sdcard/Pictures ~/Desktop
adb pull /sdcard/Screenshots ~/Desktop

#adb push *.tcl /mnt/sdcard/de1plus/
#adb pull /mnt/sdcard/de1plus/log.txt /tmp/log.txt
#adb push skins/Insight/*.tcl /mnt/sdcard/de1plus/skins/Insight;adb push skins/default/*.tcl /mnt/sdcard/de1plus/skins/default; adb push *.tcl /mnt/sdcard/de1plus/
#

#restore settings
adb push /tmp/settings.tdb /mnt/sdcard/de1plus/settings.tdb 

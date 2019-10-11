#!/bin/bash

./makede1.tcl

# back up settings
adb pull /mnt/sdcard/de1plus/settings.tdb /tmp/settings.tdb

adb shell rm -rf /mnt/sdcard/de1plus
adb push /d/download/sync/de1plus /mnt/sdcard/de1plus

#adb push *.tcl /mnt/sdcard/de1plus/
#adb pull /mnt/sdcard/de1plus/log.txt /tmp/log.txt

#restore settings
adb push /tmp/settings.tdb /mnt/sdcard/de1plus/settings.tdb 

#!/bin/bash

./makede1.tcl

# back up settings
#adb pull /mnt/sdcard/de1plus/settings.tdb /tmp/settings.tdb

#adb shell rm -rf /mnt/sdcard/de1plus
#adb push /d/download/sync/de1plus /mnt/sdcard/de1plus
#adb pull /sdcard/Pictures ~/Desktop
#adb pull /sdcard/Screenshots ~/Desktop

#adb push *.tcl /mnt/sdcard/de1plus/
adb pull /mnt/sdcard/de1plus/log.txt /tmp/log.txt
#mv /tmp/log.txt log_$SECONDS.txt
#skins/SWDark3/*.tcl skins/SWDark4/*.tcl 
adb push --sync skins/Insight/*.tcl /mnt/sdcard/de1plus/skins/Insight;adb push --sync skins/default/*.tcl /mnt/sdcard/de1plus/skins/default; adb push --sync *.tcl /mnt/sdcard/de1plus/; 
#adb push --sync profiles/* /mnt/sdcard/de1plus/profiles
#adb push --sync fw/*.dat /mnt/sdcard/de1plus/fw
#adb push --sync fonts/* /mnt/sdcard/de1plus/fonts

#rm up.zip
#rm -rf de1plus
#mkdir de1plus
#mkdir -p de1plus/skins/Insight
#mkdir -p de1plus/skins/default
#mkdir de1plus
#cp *.tcl de1plus/.
#cp skins/Insight/*.tcl de1plus/skins/Insight/.
#cp skins/default/*.tcl de1plus/skins/default/.
#zip -r de1plus_up.zip de1plus
#rm -rf de1plus

#

#restore settings
#adb push /tmp/settings.tdb /mnt/sdcard/de1plus/settings.tdb 

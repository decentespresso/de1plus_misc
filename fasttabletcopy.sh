#!/bin/bash

../misc/makede1.tcl

# back up settings
#adb pull /mnt/sdcard/de1plus/settings.tdb /tmp/settings.tdb

#adb shell rm -rf /mnt/sdcard/de1plus
#adb push /d/download/sync/de1plus /mnt/sdcard/de1plus
#adb pull /sdcard/Pictures ~/Desktop
#adb pull /sdcard/Screenshots ~/Desktop

#adb push *.tcl /mnt/sdcard/de1plus/
adb pull /sdcard/de1plus/log.txt /tmp/log.txt
#adb pull /sdcard/de1plus/history /tmp/history/
#mv /tmp/log.txt log_$SECONDS.txt
#skins/SWDark3/*.tcl skins/SWDark4/*.tcl 
adb push --sync skins/Insight/*.tcl /sdcard/de1plus/skins/Insight;adb push --sync skins/default/*.tcl /sdcard/de1plus/skins/default; adb push --sync *.tcl /sdcard/de1plus/; 
#adb push --sync doc/quickstart_one.html /sdcard/de1plus/doc/
#adb push --sync profiles/* /sdcard/de1plus/profiles
#adb push --sync fw/*.dat /sdcard/de1plus/fw
adb push --sync skins/Streamline/* /sdcard/de1plus/skins/Streamline/
adb push --sync skins/Streamline\ Dark/* /sdcard/de1plus/skins/Streamline\ Dark/
adb push --sync skins/default/* /sdcard/de1plus/skins/default/
adb push --sync fonts/* /sdcard/de1plus/fonts
adb push --sync plugins/* /sdcard/de1plus/plugins
adb push --sync profile_editors/* /sdcard/de1plus/profile_editors/
adb push --sync apk/* /sdcard/de1plus/apk
adb push --sync plugins/* /sdcard/de1plus/plugins

#adb push --sync ../de1plus/* /sdcard/de1plus/
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
#adb pull /sdcard/de1plus/settings.tdb /tmp/settings.tdb
#adb push /tmp/settings.tdb /mnt/sdcard/de1plus/settings.tdb 

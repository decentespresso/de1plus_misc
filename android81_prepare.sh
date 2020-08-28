#!/bin/bash

###############################
# NOTES:
# first put the tablet manually into adb-receptive mode
# user must go to "settings/about" and tap repeatedly on "build number"
# user then chooses "developer options" and "developer options: on" and then "usb debugging: on"
# 
# keycode docs: http://thecodeartist.blogspot.hk/2011/03/simulating-keyevents-on-android-device.html https://developer.android.com/reference/android/view/KeyEvent.html http://publish.illinois.edu/weiyang-david/2013/08/08/code-numbers-for-adb-input/
# more keycode docs: https://stackoverflow.com/questions/7789826/adb-shell-input-events
###############################

# if there are any parameters on the url then this is a DE1+ tablet pre, otherwise this is a DE1 tablet prep
tableterase=0
if [ "$1" != "" ] 
then
   tableterase=1;
fi

###############################
# optional: reset the tablet to factory settings (requires user to then proceed through setup menu)
if [ $tableterase = 1 ] 
then
	adb shell am broadcast -a android.intent.action.MASTER_CLEAR; 
	sleep 60
	adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 2; done; input keyevent 3'
	adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 2; done; input keyevent 3'
	adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 2; done; input keyevent 3'
	adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 2; done; input keyevent 3'
	adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 2; done; input keyevent 3'
fi

###############################
# go to home screen
adb shell input keyevent KEYCODE_HOME
###############################



###############################
# make the display bright
echo "Setting screen brightness to max"
adb shell 'echo 255 > /sys/devices/platform/leds-mt65xx/leds/lcd-backlight/brightness'
###############################


###############################
# set screen timeout to 30 minutes, when not plugged in
# note: maybe not needed any longer since we are replacing the global settings.db
echo "Setting screen timeout to 'never'"
adb shell settings put system screen_off_timeout 2147483646
adb shell svc power stayon true

# and for good measure disable screen timeout while plugged in
# note: maybe not needed any longer since we are replacing the global settings.db
#echo "Setting screen on when plugged in"
#adb shell settings put global stay_on_while_plugged_in 3

###############################


###############################
# disable screen swipe lock
echo "Disabling screen swipe to lock"
adb shell am force-stop com.android.settings 
#sleep 0.3
adb shell input keyevent KEYCODE_HOME
sleep 0.3
adb shell am start -a android.intent.action.MAIN -n com.android.settings/.SecuritySettings
#sleep 0.3
adb shell input tap 700 200
sleep 0.3
adb shell input tap 700 150
sleep 0.5
adb shell am force-stop com.android.settings 
###############################

###############################
# enable file copying over USB
#adb shell svc usb setFunction adb,mtp
###############################

###############################
# enable "show taps" on screen
adb shell content insert --uri content://settings/system --bind name:s:show_touches --bind value:i:1
###############################


###############################
# disable Google FTP account locking feature, as it's very annoying
# https://blog.sombex.com/2018/01/all-adb-and-fastboot-commands-to-remove-frp-lock-on-android-phones.html
adb shell content insert --uri content://settings/secure --bind name:s:user_setup_complete --bind value:s:1
###############################

###############################
# enable bluetooth
# echo "Enabling bluetooth"
# john 19-11-19 not needed for android 8.1 as BLE is on by default
#adb shell service call bluetooth_manager 8
#adb shell service call bluetooth_manager 6
###############################


###############################
# copy our source files over
echo "Copying DE1+ software"
adb shell rm -rf /mnt/sdcard/de1plus
adb shell rm -rf /mnt/sdcard/backup_de1plus
adb push /d/download/sync/de1plus /mnt/sdcard/de1plus
echo "Making backup on tablet of DE1+ software"
adb shell cp -R /sdcard/de1plus /sdcard/backup_de1plus &
###############################


###############################
# install wallpaper
#adb pull /data/system/users/0/wallpaper
#adb pull /data/system/users/0/wallpaper_info.xml
echo "Setting wallpaper"
adb push android/wallpaper_info.xml /data/system/users/0/wallpaper_info.xml
adb push wallpaper/spy_1280x800.jpg /data/system/users/0/wallpaper
###############################


###############################
# install androwish
echo "Installing Androwish"
adb install android/androwish.apk 
adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW 
sleep 2
adb shell input tap 1270 680
sleep 1
adb shell am force-stop tk.tcl.wish
###############################

###############################
# replace the launcher3 database with our own, which moves the icons where we want them and removes all tne toolbar noise of all those google icons
# adb pull /data/data/com.android.launcher3/databases/launcher.db android/launcher.db.de1plus81b
# adb pull /data/data/com.android.launcher3/databases/app_icons.db android/app_icons.db81b
# adb pull /data/data/com.android.launcher3/databases/widgetpreviews.db android/widgetpreviews.db81b

echo "Creating de1+ icon"
adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1plus/create_de1plus_icon.tcl
sleep 3
echo "Tapping on system dialog to accept de1+ icon"
adb shell input tap 900 530
sleep 1
adb shell am force-stop tk.tcl.wish
sleep 1

echo "Creating cloud update icon"
adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1plus/create_de1_update_icon.tcl
sleep 3
echo "Tapping on system dialog to accept cloud upload icon"
adb shell input tap 900 530
sleep 1
adb shell am force-stop tk.tcl.wish

adb push android/launcher.db.de1plus81 /data/data/com.android.launcher3/databases/launcher.db
adb shell am force-stop com.android.launcher3


#adb push android/app_icons.db81 /data/data/com.android.launcher3/databases/app_icons.db
#adb push android/widgetpreviews.db81 /data/data/com.android.launcher3/databases/widgetpreviews.db

###############################

###############################
# install Chrome
echo "Installing Chrome"
adb install android/chrome.apk 
adb shell am start -n com.android.chrome/com.google.android.apps.chrome.Main
sleep 3
adb shell input tap 1270 680
sleep 3
adb shell input tap 670 660
sleep 1
adb shell input keyevent KEYCODE_HOME
###############################

###############################
# install Chrome
echo "Installing File Manager +"
adb install android/filemanager.apk 
###############################


adb shell am restart 

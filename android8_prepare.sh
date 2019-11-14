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
# go to home screen
adb shell input keyevent KEYCODE_HOME
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
# install androwish
echo "Installing Androwish"
adb install android/androwish.apk
###############################

###############################
# copy our source files over
echo "Copying DE1+ software"
adb shell rm -rf /mnt/sdcard/de1plus
adb shell rm -rf /mnt/sdcard/backup_de1plus
adb push /d/download/sync/de1plus /mnt/sdcard/de1plus
echo "Making backup on tablet of DE1+ software"
adb shell cp -R /sdcard/de1plus /sdcard/backup_de1plus
###############################

###############################
# install wallpaper
#adb pull /data/system/users/0/wallpaper
#adb pull /data/system/users/0/wallpaper_info.xml
echo "Setting wallpaper"
adb push android/wallpaper_info.xml /data/system/users/0/wallpaper_info.xml
adb push android/wallpaper /data/system/users/0/wallpaper
###############################


###############################
# replace the launcher3 database with our own, which moves the icons where we want them and removes all tne toolbar noise of all those google icons
# adb pull /data/data/com.android.launcher3/databases/launcher.db android/launcher.db.de1plus81
# adb pull /data/data/com.android.launcher3/databases/app_icons.db android/app_icons.db81
# adb pull /data/data/com.android.launcher3/databases/widgetpreviews.db android/widgetpreviews.db81
adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1plus/create_de1plus_icon.tcl
sleep 2
adb shell input tap 900 530
adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1plus/create_de1_update_icon.tcl
sleep 2
adb shell input tap 900 530
adb push android/launcher.db.de1plus81 /data/data/com.android.launcher3/databases/launcher.db
adb push android/app_icons.db81 /data/data/com.android.launcher3/databases/app_icons.db
adb push android/widgetpreviews.db81 /data/data/com.android.launcher3/databases/widgetpreviews.db
adb shell am restart com.android.launcher3
sleep 2
adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 2; done; input keyevent 3'
###############################

###############################
# pair with DE1 via bluetooth
# from https://android.stackexchange.com/questions/83726/how-to-adb-wait-for-device-until-the-home-screen-shows-up
echo "Launching DE1+ tablet software for final testing"
#adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1plus/de1plus.tcl



exit



###############################






###############################


###############################
# changes to global settings sqlite table
# turn global/bluetooth_on to 1
# global/device_name to "Decent Tablet"
# system/dim_screen 0
# system/screen_brightness 255
# secure/lockscreen.disabled 1
# secure/bluetooth_name "Decent Tablet"
# adb pull /data/data/com.android.providers.settings/databases/settings.db android/settings3b.db
echo "Replacing system settings"
adb push android/settings.db /data/data/com.android.providers.settings/databases/settings.db
###############################



###############################
# replace the launcher3 database with our own, which moves the icons where we want them and removes all tne toolbar noise of all those google icons
# adb pull /data/data/com.android.launcher3/databases/launcher.db android/launcher.db.de1
# adb pull /data/data/com.android.launcher3/databases/launcher.db android/launcher.db.de1plus
#
# optional: create our app icons with code
# note: need to manually drag the icons to their desired place
# note #2 : this is not needed since we are wiping out the launcher.db with our own in the next line. This script is only used
# to create the icons the first time, and then we use the sqlite table to restore them to a new tablet
# adb shell am start -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///mnt/sdcard/de1plus/create_de1plus_icon.tcl
# adb shell am start -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1/create_de1_icon.tcl
#

#if [ $de1plus = 0 ] 
#then
#	echo "Replacing DE1 launcher settings"
#	adb push android/launcher.db.de1 /data/data/com.android.launcher3/databases/launcher.db
#else 
	echo "Replacing DE1+ launcher settings"
	adb push android/launcher.db.de1plus1 /data/data/com.android.launcher3/databases/launcher.db
#fi

###############################


###############################
# lower volume to zero
# from https://developer.android.com/reference/android/view/KeyEvent
adb shell input keyevent KEYCODE_VOLUME_DOWN
adb shell input keyevent KEYCODE_VOLUME_DOWN
adb shell input keyevent KEYCODE_VOLUME_DOWN
adb shell input keyevent KEYCODE_VOLUME_DOWN
adb shell input keyevent KEYCODE_VOLUME_DOWN
adb shell input keyevent KEYCODE_VOLUME_DOWN
adb shell input keyevent KEYCODE_VOLUME_DOWN
adb shell input keyevent KEYCODE_VOLUME_DOWN
adb shell input keyevent KEYCODE_VOLUME_DOWN
adb shell input keyevent KEYCODE_VOLUME_DOWN
###############################



###############################
# enable wifi
# note: maybe not needed any longer since we are replacing the global settings.db
#echo "Setting wifi on"
#adb shell settings put global wifi_on 1
adb shell settings put global wifi_on 0
adb shell settings put global wifi_scan_always_enabled 0
adb shell settings put global wifi_watchdog_on 0
adb shell svc wifi disable
###############################



###############################
echo "Rebooting tablet"
adb reboot
sleep 15
adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 2; done; input keyevent 3'
adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 2; done; input keyevent 3'
adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 2; done; input keyevent 3'
adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 2; done; input keyevent 3'
###############################


###############################
# pair with DE1 via bluetooth
#if [ $de1plus = 0 ] 
#then
	#echo "Auto-pairing with DE1"
	#adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1/autopair_with_de1.tcl
#else 
	#echo "Auto-pairing with DE1+"
	#adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1plus/autopair_with_de1plus.tcl
#fi

# wait for a few seconds seconds for this happen
#sleep 10
###############################


###############################
# pair with DE1 via bluetooth
# from https://android.stackexchange.com/questions/83726/how-to-adb-wait-for-device-until-the-home-screen-shows-up
#if [ $de1plus = 0 ] 
#then
#	echo "Launching DE1 tablet software for final testing"
#	adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1/de1.tcl
#else 
	echo "Launching DE1+ tablet software for final testing"
	adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1plus/de1plus.tcl
#fi

###############################


# update supersu binary


#adb reboot
#adb shell am force-stop com.android.launcher3 

exit

###############################################################################################


# everything below is historical attempts and no longer used.


# todo: move icons to their rightful place?


#

# install wallpaper
adb shell am start -a android.app.WallpaperManager -c android.intent.ACTION_CHANGE_LIVE_WALLPAPER  -d file:///mnt/sdcard/de1/wallpaper/spy_2560x1600.jpg  -t 'image/jpeg'  -e mimeType 'image/jpeg'
adb shell input tap 500 700
adb shell input tap 600 600 
adb shell input tap 600 600 
adb reboot

exit


adb shell uiautomator

adb shell input tap 200 200 & PIDTAP=$!
adb shell input swipe 200 200 200 100 1000 & PIDSWIPE=$!
wait $PIDTAP
wait $PIDSWIPE

# all keycodes
#http://thecodeartist.blogspot.hk/2011/03/simulating-keyevents-on-android-device.html

###################
# example - set FRENCH as the system language. The "swipe" command is the crucial one to get precisely right
adb shell input keyevent KEYCODE_HOME
adb shell am start -a android.intent.action.MAIN -n com.android.settings/.LanguageSettings
sleep 1
adb shell input keyevent KEYCODE_ENTER
sleep 1
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_ENTER
sleep 1
adb shell input keyevent KEYCODE_HOME
###################

###################
# example - set ENGLISH USA as the system language. The "swipe" command is the crucial one to get precisely right
adb shell input keyevent KEYCODE_HOME
adb shell am start -a android.intent.action.MAIN -n com.android.settings/.LanguageSettings
sleep 1
adb shell input keyevent KEYCODE_ENTER
sleep 1
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_DPAD_DOWN
adb shell input keyevent KEYCODE_ENTER
sleep 1
adb shell input keyevent KEYCODE_HOME
###################

adb shell am start tk.tcl.wish/.AndroWishLauncher --es "android.intent.extra.TEXT" "/sdcard/de1plus/create_de1plus_icon.tcl"   -t "text/plain"

adb shell am start tk.tcl.wish/.AndroWishLauncher --es "android.intent.extra.TEXT" "/sdcard/de1plus/create_de1plus_icon.tcl"   -t "text/plain"

adb shell am start tk.tcl.wish/.AndroWishLauncher --es "android.intent.extra.TEXT" "/sdcard/de1/create_de1_icon.tcl"   -t "text/plain"


adb shell am start -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1/create_de1_icon.tcl

adb shell am start -a "android.intent.action.SEND" --es "android.intent.extra.TEXT" "Hello World" -t "text/plain"


adb shell am start -a "android.intent.action.VIEW" -d "http://developer.android.com"





/sys/devices/platform/leds-mt65xx/leds/lcd-backlight

stty raw -echo ; ( echo "255" > /sys/devices/platform/leds-mt65xx/leds/lcd-backlight && exit ) | adb shell ; stty sane 

stty raw -echo ; ( echo 255 > /sys/devices/platform/leds-mt65xx/leds/lcd-backlight/brightness ) | adb shell ; stty sane 

adb push /tmp/1 /sys/devices/platform/leds-mt65xx/leds/lcd-backlight

adb push /tmp/brightness /sys/devices/platform/leds-mt65xx/leds/lcd-backlight/brightness

adb shell 'echo 255 > /sys/devices/platform/leds-mt65xx/leds/lcd-backlight/brightness'


adb shell input keyevent 26
adb shell input keyevent 82

adb shell settings put system screen_off_timeout 60000
adb shell settings put system screen_off_timeout 2147483646


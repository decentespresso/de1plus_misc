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
de1plus=0
if [ "$1" != "" ] 
then
   de1plus=1;
fi


###############################
# optional: reset the tablet to factory settings (requires user to then proceed through setup menu)
adb shell am broadcast -a android.intent.action.MASTER_CLEAR; sleep 10
adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done; input keyevent 3'
###############################

###############################
# make the display bright
echo "Setting screen brightness to max"
adb shell 'echo 255 > /sys/devices/platform/leds-mt65xx/leds/lcd-backlight/brightness'
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
adb shell am force-stop com.android.settings
sleep 1
adb shell input keyevent KEYCODE_HOME
###############################

###############################
# set screen timeout to 30 minutes, when not plugged in
# note: maybe not needed any longer since we are replacing the global settings.db
echo "Setting screen timeout to 'never'"
#adb shell settings put system screen_off_timeout 2147483646
adb shell settings put system screen_off_timeout 360000
###############################

###############################
# disable screen swipe lock
echo "Disabling screen swipe to lock"
adb shell am force-stop com.android.settings 
#sleep 1
adb shell input keyevent KEYCODE_HOME
#sleep 1
adb shell am start -a android.intent.action.MAIN -n com.android.settings/.SecuritySettings
#sleep 1
adb shell input swipe 100 100 100 500 100
#sleep 1
adb shell input keyevent KEYCODE_ENTER
#sleep 1
adb shell input keyevent KEYCODE_ENTER
#sleep 1
adb shell input keyevent KEYCODE_ENTER
#sleep 1
adb shell am force-stop com.android.settings 
###############################


###############################
# run supersu so that the user gets prompted to update the app, which causes a reboot afterwards
# user should click OK to supersu update promps, IF a supersu update is needed.
# supersu updates survive a factory reset, so they only need to be done once per tablet
adb shell am start -W -a android.intent.action.MAIN -n eu.chainfire.supersu/.MainActivity
###############################

###############################
# and for good measure disable screen timeout while plugged in
# note: maybe not needed any longer since we are replacing the global settings.db
echo "Setting screen on when plugged in"
adb shell settings put global stay_on_while_plugged_in 3
###############################

###############################
# enable bluetooth
# echo "Enabling bluetooth"
adb shell service call bluetooth_manager 8
adb shell service call bluetooth_manager 6
###############################

###############################
# enable wifi
# note: maybe not needed any longer since we are replacing the global settings.db
#echo "Setting wifi on"
adb shell settings put global wifi_on 1
###############################

###############################
# install androwish
echo "Installing Androwish"
adb install android/androwish.apk
###############################

###############################
# copy our source files over
#adb push /d/download/sync/de1plus /mnt/sdcard/de1plus
if [ $de1plus = 0 ] 
then
	echo "Copying DE1 software"
	adb push /d/download/sync/de1 /mnt/sdcard/de1
else 
	echo "Copying DE1+ software"
	adb push /d/download/sync/de1plus /mnt/sdcard/de1plus
fi


###############################


###############################
# changes to global settings sqlite table
# turn global/bluetooth_on to 1
# global/device_name to "Decent Tablet"
# system/dim_screen 0
# system/screen_brightness 255
# secure/lockscreen.disabled 1
# secure/bluetooth_name "Decent Tablet"
#adb pull /data/data/com.android.providers.settings/databases/settings.db android/settings.db
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
# adb shell am start -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1plus/create_de1plus_icon.tcl
# adb shell am start -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1/create_de1_icon.tcl
#

if [ $de1plus = 0 ] 
then
	echo "Replacing DE1 launcher settings"
	adb push android/launcher.db.de1 /data/data/com.android.launcher3/databases/launcher.db
else 
	echo "Replacing DE1+ launcher settings"
	adb push android/launcher.db.de1plus /data/data/com.android.launcher3/databases/launcher.db
fi

###############################


###############################
echo "Rebooting tablet"
adb reboot
sleep 5
adb wait-for-device shell 'while [[ -z $(getprop sys.boot_completed) ]]; do sleep 1; done; input keyevent 3'
###############################


###############################
# pair with DE1 via bluetooth
if [ $de1plus = 0 ] 
then
	echo "Auto-pairing with DE1"
	adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1/autopair_with_de1.tcl
else 
	echo "Auto-pairing with DE1+"
	adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1plus/autopair_with_de1plus.tcl
fi

# wait for a few seconds seconds for this happen
sleep 10
###############################

###############################
# pair with DE1 via bluetooth
# from https://android.stackexchange.com/questions/83726/how-to-adb-wait-for-device-until-the-home-screen-shows-up
if [ $de1plus = 0 ] 
then
	echo "Launching DE1 tablet software for final testing"
	adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1/de1.tcl
else 
	echo "Launching DE1+ tablet software for final testing"
	adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1plus/de1plus.tcl
fi

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
adb shell am start -a android.app.WallpaperManager -c android.intent.ACTION_CHANGE_LIVE_WALLPAPER  -d file:///sdcard/de1/wallpaper/spy_2560x1600.jpg  -t 'image/jpeg'  -e mimeType 'image/jpeg'
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


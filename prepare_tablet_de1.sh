#!/bin/bash

###############################
# NOTES:
# first put the tablet manually into adb-receptive mode
# user must go to "settings/about" and tap repeatedly on "build number"
# user then chooses "developer options" and "developer options: on" and then "usb debugging: on"
# 
# keycode docs: http://thecodeartist.blogspot.hk/2011/03/simulating-keyevents-on-android-device.html https://developer.android.com/reference/android/view/KeyEvent.html http://publish.illinois.edu/weiyang-david/2013/08/08/code-numbers-for-adb-input/
###############################

###############################
# set screen timeout to 30 minutes, when not plugged in
# note: maybe not needed any longer since we are replacing the global settings.db
adb shell settings put system screen_off_timeout 1800000
###############################

###############################
# and for good measure disable screen timeout while plugged in
# note: maybe not needed any longer since we are replacing the global settings.db
adb shell settings put global stay_on_while_plugged_in 3
###############################

###############################
# enable wifi
# note: maybe not needed any longer since we are replacing the global settings.db
adb shell settings put global wifi_on 1
###############################


###############################
# make the display bright
adb shell 'echo 255 > /sys/devices/platform/leds-mt65xx/leds/lcd-backlight/brightness'
###############################

###############################
# copy our source files over
#adb push /d/download/sync/de1plus /mnt/sdcard/de1plus
adb push /d/download/sync/de1 /mnt/sdcard/de1
###############################

###############################
# install androwish
adb install androwish/androwish.apk
###############################

###############################
# create our app icons
# note: need to manually drag the icons to their desired place, and also manually remove
# note #2 : this may not be needed any longer since we are wiping out the launcher.db with our own in the next line
adb shell am start -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1/create_de1_icon.tcl
###############################

###############################
# replace the launcher3 database with our own, which moves the icons where we want them and removes all tne toolbar noise of all those google icons
#adb pull /data/data/com.android.launcher3/databases/launcher.db
adb push android/launcher.db.de1 /data/data/com.android.launcher3/databases/launcher.db
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
adb push settings.db /data/data/com.android.providers.settings/databases/settings.db
###############################

###############################
# install wallpaper
#adb pull /data/system/users/0/wallpaper
#adb pull /data/system/users/0/wallpaper_info.xml
adb push android/wallpaper_info.xml /data/system/users/0/wallpaper_info.xml
adb push android/wallpaper /data/system/users/0/wallpaper
###############################

###############################
# disable screen swipe lock
adb shell am force-stop com.android.settings 
adb shell input keyevent KEYCODE_HOME
sleep 1
adb shell am start -a android.intent.action.MAIN -n com.android.settings/.SecuritySettings
sleep 1
adb shell input keyevent KEYCODE_ENTER
sleep 1
adb shell input keyevent KEYCODE_ENTER
sleep 1
adb shell am force-stop com.android.settings 
###############################

adb reboot



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
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

# disable rotation
adb shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:0
adb shell content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:1

###############################
# go to home screen
adb shell input keyevent KEYCODE_HOME
###############################



###############################
# make the display bright
echo "Setting screen brightness to max"
adb shell settings put system screen_brightness 255
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
# disable screen swipe lock
echo "Disabling screen swipe to lock"
adb shell am start -a android.settings.SECURITY_SETTINGS
sleep 0.5
adb shell input tap 700 600
sleep 0.3
adb shell input tap 200 150
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
# adb shell am start -a android.settings.BLUETOOTH_SETTINGS
# adb shell input tap 200 300
# adb shell am force-stop com.android.settings 
###############################


###############################
# copy our source files over
echo "Copying Tablet App"
#adb shell rm -rf /mnt/sdcard/de1plus
#adb shell rm -rf /mnt/sdcard/backup_de1plus
adb push /d/download/sync/de1plus /mnt/sdcard/de1plus
echo "Making backup on tablet of DE1+ software"
adb shell cp -R /sdcard/de1plus /sdcard/backup_de1plus &
###############################

###############################
# install File Manager +
echo "Installing File Manager +"
adb install android/filemanager.apk 
###############################

###############################
# disable google home screen app 
adb shell input draganddrop 200 200 200 200 1000
adb shell input tap 365 425
adb shell input tap 1233 163
adb shell input keyevent KEYCODE_HOME

###############################
# install wallpaper
#adb pull /data/system/users/0/wallpaper
#adb pull /data/system/users/0/wallpaper_info.xml
echo "Setting wallpaper"
#adb push android/wallpaper_info.xml /data/system/users/0/wallpaper_info.xml
#adb push wallpaper/spy_1280x800.jpg /data/system/users/0/wallpaper

adb shell am start -a android.intent.action.ATTACH_DATA -c android.intent.category.DEFAULT -d file:///mnt/sdcard/de1plus/wallpaper/spy_2560x1600.jpg -t 'image/*'  -e mimeType 'image/*'
sleep 3
adb shell input tap 610 630
sleep 3
adb shell input tap 910 690
sleep 3
adb shell input tap 140 50
sleep 3
adb shell input tap 450 480
sleep 3
adb shell input tap 690 690
sleep 1
adb shell content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:1
sleep 0.3
adb shell am force-stop com.android.settings 
sleep 0.3
adb shell input keyevent KEYCODE_HOME
sleep 0.3

###############################

###############################
# install androwish
echo "Installing Androwish"
adb install android/androwish.apk 
sleep 0.3
adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW 
sleep 2
# supressing "old app" warning
adb shell input tap 963 450
sleep 1
adb shell am force-stop tk.tcl.wish
###############################


###############################
# enable do not disturb
adb shell input draganddrop 640 13 640 400 100
adb shell input tap 605 125
adb shell input tap 200 200

###############################
# replace the launcher3 database with our own, which moves the icons where we want them and removes all tne toolbar noise of all those google icons
# adb pull /data/data/com.android.launcher3/databases/launcher.db android/launcher.db.de1plus81b
# adb pull /data/data/com.android.launcher3/databases/app_icons.db android/app_icons.db81b
# adb pull /data/data/com.android.launcher3/databases/widgetpreviews.db android/widgetpreviews.db81b

# remove 3 icons on the bottom
adb shell input draganddrop 170 650 25 100 100
sleep 0.3
adb shell input draganddrop 340 650 25 100 100
sleep 0.3
adb shell input draganddrop 1050 650 25 100 100
sleep 0.3

# remove sidebar icons
adb shell input draganddrop 1250 650 25 100 100
sleep 0.3
adb shell input draganddrop 1250 650 25 100 100
sleep 0.3
adb shell input draganddrop 1250 650 25 100 100
sleep 0.3
adb shell input draganddrop 1250 560 25 100 100
sleep 0.3
adb shell input draganddrop 1250 390 25 100 100
sleep 0.3


echo "Creating de1+ icon"
#adb shell 'echo default_font_calibration .6 >>/mnt/sdcard/de1plus/settings.tdb'
adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1plus/create_de1plus_icon.tcl
sleep 3
echo "Tapping on system dialog to accept de1+ icon"
adb shell input tap 900 530
sleep 1
adb shell am force-stop tk.tcl.wish
sleep 1

# move the Decent icon
#adb shell input draganddrop 160 120 600 400 100
adb shell input draganddrop 160 120 0 500 100
sleep 1
adb shell input draganddrop 1080 510 700 385 1000
sleep 1

echo "Creating cloud update icon"
adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1plus/create_de1_update_icon.tcl
sleep 3
echo "Tapping on system dialog to accept cloud upload icon"
adb shell input tap 900 530
sleep 1
adb shell am force-stop tk.tcl.wish
# move the cloud update icon
adb shell input draganddrop 160 120 700 400 100
sleep 0.3
# moveing back to home page
adb shell input keyevent KEYCODE_HOME

###############################
# connect to decent wifi
adb shell am start -a android.settings.WIFI_SETTINGS
sleep 0.5
adb shell input tap 640 245
sleep 0.5
adb shell input text decent99
sleep 0.5
adb shell input keyevent 66

# run decent app to confirm 
adb shell am start -W -n tk.tcl.wish/.AndroWishLauncher -a android.intent.action.ACTION_VIEW -e arg file:///sdcard/de1plus/de1plus.tcl

adb shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:1
adb shell content insert --uri content://settings/system --bind name:s:user_rotation --bind value:i:1

###############################
# disable developer mode so that people aren't asked if they want to trust this pc
# adb shell settings put global development_settings_enabled 0
# adb reboot

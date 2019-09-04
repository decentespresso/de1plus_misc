#!/bin/bash

# back up settings
adb pull /mnt/sdcard/de1plus/settings.tdb /tmp/settings.tdb

adb shell rm -rf /mnt/sdcard/de1plus
adb push /d/download/sync/de1plus /mnt/sdcard/de1plus

#restore settings
adb push /tmp/settings.tdb /mnt/sdcard/de1plus/settings.tdb 

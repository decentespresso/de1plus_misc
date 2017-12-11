#!/bin/bash

convert ~/Desktop/skin0000.tif nothing_on.png & 
convert ~/Desktop/skin0001.tif espresso_on.png &
convert ~/Desktop/skin0002.tif steam_on.png &
convert ~/Desktop/skin0003.tif tea_on.png &
wait

rm  ~/Desktop/skin0000.tif 
rm  ~/Desktop/skin0001.tif 
rm  ~/Desktop/skin0002.tif 
rm  ~/Desktop/skin0003.tif 

convert nothing_on.png -resize 640x400 icon.jpg &

zopflipng -q --iterations=1 -y   nothing_on.png nothing_on.png &
zopflipng -q --iterations=1 -y   espresso_on.png espresso_on.png &
zopflipng -q --iterations=1 -y   steam_on.png steam_on.png &
zopflipng -q --iterations=1 -y   tea_on.png tea_on.png &
wait

exit

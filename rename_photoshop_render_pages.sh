#!/bin/bash

convert -strip ~/Desktop/skin0000.tif nothing_on.png & 
convert -strip ~/Desktop/skin0001.tif espresso_on.png &
convert -strip ~/Desktop/skin0002.tif steam_on.png &
convert -strip ~/Desktop/skin0003.tif tea_on.png &
wait

rm  ~/Desktop/skin0000.tif 
rm  ~/Desktop/skin0001.tif 
rm  ~/Desktop/skin0002.tif 
rm  ~/Desktop/skin0003.tif 

convert nothing_on.png -resize 640x400 icon.jpg &

zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y   nothing_on.png nothing_on.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y   espresso_on.png espresso_on.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y   steam_on.png steam_on.png &
zopflipng --always_zopflify --lossy_transparent -q --iterations=1 -y   tea_on.png tea_on.png &
wait

exit

#!/bin/bash

echo "You need FFMPEG to make this work https://www.ffmpeg.org/download.html\n"

(sleep 1; echo "Connect to the Decent App at http://localhost:8080") &
export SDL_VIDEODRIVER=jsmpeg
export SDL_VIDEO_JSMPEG_OUTFILE=~/Desktop/decent.mpg
#export SDL_VIDEO_JSMPEG_AUTH=$(echo -n user:pass | base64)
cd ..
MacOS/wish Resources/de1plus/de1plus.tcl  -sdlheight 800 -sdlwidth 1280 -sdlrootheight 800 -sdlrootwidth 1280 -name Decent

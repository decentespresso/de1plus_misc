#!/bin/bash

echo "You need FFMPEG to make this work https://www.ffmpeg.org/download.html"

(sleep 1; echo "Connect to the Decent App at http://localhost:8080") &
export SDL_VIDEODRIVER=jsmpeg
export SDL_VIDEO_JSMPEG_PORT=8080
#export SDL_VIDEO_JSMPEG_OUTFILE=/tmp/decent.mpg
#export SDL_VIDEO_JSMPEG_AUTH=$(echo -n user:pass | base64)
undroidwish/undroidwish-wayland64 src/de1plus.tcl -sdlwidth 1280 -sdlheight 800 -name "Decent"

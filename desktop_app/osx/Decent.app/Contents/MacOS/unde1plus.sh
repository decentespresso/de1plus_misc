#!/bin/bash

(sleep 1; echo "Connect to the Decent App at http://localhost:8080") &
export SDL_VIDEODRIVER=jsmpeg
export SDL_VIDEO_JSMPEG_OUTFILE=~/Desktop/decent.mpg
cd ..
MacOS/undroidwish Resources/de1plus/de1plus.tcl  -sdlheight 800 -sdlwidth 1280 -sdlrootheight 800 -sdlrootwidth 1280 -name Decent

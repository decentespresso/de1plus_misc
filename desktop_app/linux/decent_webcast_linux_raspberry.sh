#!/bin/bash

(sleep 1; echo "Connect to the Decent App at http://localhost:8080") &
export SDL_VIDEODRIVER=jsmpeg
export SDL_VIDEO_JSMPEG_OUTFILE=/tmp/decent.mpg
undroidwish/undroidwish-raspberry src/de1plus.tcl -sdlwidth 1280 -sdlheight 800 -name "Decent"

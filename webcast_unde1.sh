#!/bin/bash

rm -rf webcast
mkdir -p webcast
cp -r /d/download/sync/de1plus webcast/.
chown -R nobody webcast
cd webcast/de1plus
echo "Starting"
export SDL_VIDEODRIVER=jsmpeg
/d/admin/code/de1beta/desktop_app//linux/undroidwish/undroidwish-linux64 de1plus.tcl  -sdlheight 800 -sdlwidth 1280 -sdlrootheight 800 -sdlrootwidth 1280 -name Decent
echo "Exiting"

echo "Connect to the Decent App at http://localhost:8080"
set SDL_VIDEODRIVER=jsmpeg
set SDL_VIDEO_JSMPEG_OUTFILE=%HOMEDRIVE%%HOMEPATH%\Desktop\decent.mpg
set SDL_VIDEO_JSMPEG_PORT 8080
undroidwish\undroidwish-win32.exe src\de1plus.tcl -sdlwidth 1280 -sdlheight 800 -name Decent

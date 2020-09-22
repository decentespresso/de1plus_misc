#!/usr/local/bin/bash

echo "Making release version of de1beta->de1plus"

file delete -force /d/download/desktop/osx/decent_osx_release.zip
file delete -force /d/download/desktop/win32/decent_win_release.zip
file delete -force /d/download/desktop/linux/decent_linux_release.zip
file delete -force /d/download/desktop/source/decent_source_release.zip
file delete -force /d/download/sync/de1plus

file copy -force /d/download/desktop/osx/decent_osx.zip /d/download/desktop/osx/decent_osx_release.zip
file copy -force /d/download/desktop/win32/decent_win.zip  /d/download/desktop/win32/decent_win_release.zip
file copy -force /d/download/desktop/linux/decent_linux.zip /d/download/desktop/linux/decent_linux_release.zip
file copy -force /d/download/desktop/source/decent_source.zip /d/download/desktop/source/decent_source_release.zip

file copy /d/download/desktop/osx/decent_osx.zip /d/download/desktop/osx/decent_osx_release.zip 
file copy /d/download/desktop/linux/decent_linux.zip /d/download/desktop/linux/decent_linux_release.zip
file copy /d/download/desktop/win32/decent_win.zip /d/download/desktop/win32/decent_win_release.zip 
file copy -force /d/download/sync/de1beta /d/download/sync/de1plus

echo "done"
#!/usr/local/bin/tclsh

puts "Making release version of de1beta->de1plus"

file delete -force /d/download/desktop/osx/decent_osx_stable.zip
file delete -force /d/download/desktop/win32/decent_win_stable.zip
file delete -force /d/download/desktop/linux/decent_linux_stable.zip
file delete -force /d/download/desktop/source/decent_source_stable.zip
file delete -force /d/download/sync/de1plus

puts "- Mac"
file copy -force /d/download/desktop/osx/decent_osx.zip /d/download/desktop/osx/decent_osx_stable.zip

puts "- Win"
file copy -force /d/download/desktop/win32/decent_win.zip  /d/download/desktop/win32/decent_win_stable.zip

puts "- Linux"
file copy -force /d/download/desktop/linux/decent_linux.zip /d/download/desktop/linux/decent_linux_stable.zip

puts "- Source"
file copy -force /d/download/desktop/source/decent_source.zip /d/download/desktop/source/decent_source_stable.zip

puts "- Sync"
file copy -force /d/download/sync/de1beta /d/download/sync/de1plus

puts "done"
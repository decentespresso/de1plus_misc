#!/usr/local/bin/tclsh

cd ../de1plus

source pkgIndex.tcl
package require de1_updater
package require de1_utils
package require de1_vars
package require de1_misc
package provide de1plus 1.0
package require sha256
package require crc32
package require snit
package require de1_gui 

cd ../misc

puts "Makede1: [exec ./makede1.tcl]"

puts "Making beta version of de1nightly->de1beta"

catch {
	file delete -force /d/download/desktop/osx/decent_osx_beta.zip
	file delete -force /d/download/desktop/win32/decent_win_beta.zip
	file delete -force /d/download/desktop/linux/decent_linux_beta.zip
	file delete -force /d/download/desktop/source/decent_source_beta.zip
	file delete -force /d/download/sync/de1beta
}

puts "- Mac"
file copy -force /d/download/desktop/osx/decent_osx.zip /d/download/desktop/osx/decent_osx_beta.zip

puts "- Win"
file copy -force /d/download/desktop/win32/decent_win.zip  /d/download/desktop/win32/decent_win_beta.zip

puts "- Linux"
file copy -force /d/download/desktop/linux/decent_linux.zip /d/download/desktop/linux/decent_linux_beta.zip

puts "- Source"
file copy -force /d/download/desktop/source/decent_source.zip /d/download/desktop/source/decent_source_beta.zip

puts "- Sync"
file copy -force /d/download/sync/de1nightly /d/download/sync/de1beta

puts "done"
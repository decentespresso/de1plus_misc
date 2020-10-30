#!/usr/local/bin/tclsh

# copies files out of the working directory (checked out from git) to a sync directory, where BETA users of the de1app can then sync to it
# also makes ZIP files of the BETA Desktop app for Linux/Windows/OSX/Source
# this is not necessarily a useful script for anyone but Decent Espresso


set synctarget "/d/download/sync"
set desktoptarget "/d/download/desktop"

set miscdir [file normalize [file dirname [info script]]]
cd  $miscdir

cd ../de1plus/
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

catch { file link  "$miscdir/desktop_app/linux/src" "$synctarget/de1beta" }
catch { file link  "$miscdir/desktop_app/osx/Decent.app/Contents/Resources/de1plus" "$synctarget/de1beta" }
catch { file link  "$miscdir/desktop_app/win32/src" "$synctarget/de1beta" }

if {$argv != ""} {
	puts "Updating apps"

	# optionally purge the source directories and resync
	# do this if we remove files from the sync list
	file delete -force "$synctarget/de1beta"
	file delete -force "$synctarget/decent"
	file mkdir "$synctarget/de1beta"
	file link "$synctarget/decent" "$synctarget/de1beta"
	file delete -force "$desktoptarget/osx/decent_osx.zip"
	file delete -force "$desktoptarget/win32/decent_win.zip"
	file delete -force "$desktoptarget/linux/decent_linux.zip"
	file delete -force "$desktoptarget/source/decent_source.zip"

	#skin_convert_all
	make_de1_dir "." [list "$synctarget/de1beta"]

	cd "$miscdir/desktop_app/osx"
	exec zip -u -x "*CVS*" -x ".DS_Store" -r "$desktoptarget/osx/decent_osx.zip" Decent.app 

	cd "$miscdir/desktop_app/win32"
	exec zip -u -x "*CVS*" -x ".DS_Store" -r "$desktoptarget/win32/decent_win.zip" ./

	cd "$miscdir/desktop_app/linux"
	file attributes "undroidwish/undroidwish-linux32" -permission 0755
	file attributes "undroidwish/undroidwish-linux64" -permission 0755
	file attributes "undroidwish/undroidwish-raspberry" -permission 0755
	file attributes "undroidwish/undroidwish-wayland64" -permission 0755

	cd "$miscdir/desktop_app/"
	file delete -force "$miscdir/desktop_app/decent"
	file link "$miscdir/desktop_app/decent" "$miscdir/desktop_app/linux"
	exec zip -x "*CVS*" -x ".DS_Store" -r "$desktoptarget/linux/decent_linux.zip" decent

	cd "$synctarget"
	exec zip -x "*CVS*" -x ".DS_Store" -r "$desktoptarget/source/decent_source.zip" de1beta

} else {
	#skin_convert_all
	make_de1_dir "." [list "$synctarget/de1beta"]

}

file delete "$miscdir/desktop_app/linux/src"
file delete "$miscdir/osx/Decent.app/Contents/Resources/de1plus"
file delete "$miscdir/win32/src"

puts "done"




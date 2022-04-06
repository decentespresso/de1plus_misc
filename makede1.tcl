#!/usr/local/bin/tclsh

# copies files out of the working directory (checked out from git) to a sync directory, where BETA users of the de1app can then sync to it
# also makes ZIP files of the BETA Desktop app for Linux/Windows/OSX/Source
# this is not necessarily a useful script for anyone but Decent Espresso

namespace eval ::logging { variable disable_logging_for_build True }

if { $argc != 2 } {
        puts "The script requires the output folder to write.\n"
        puts "for example:\n\n../misc/makede1.tcl nightly 1\n"
        return
}

set release_target [lindex $argv 0]
set synctarget "/d/download/sync"
set desktoptarget "/d/download/desktop/$release_target"

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

catch { file link  "$miscdir/desktop_app/linux/src" "$synctarget/$release_target" }
catch { file link  "$miscdir/desktop_app/osx/Decent.app/Contents/Resources/de1plus" "$synctarget/$release_target" }
catch { file link  "$miscdir/desktop_app/win32/src" "$synctarget/$release_target" }

if {[lindex $argv 1] == "1"} {
	puts "Updating apps"

	# old comment - optionally purge the source directories and resync
	# do this if we remove files from the sync list

	# new comment 17-5-21 : since git removes stale files, but cvs does not, we can now skip 
	# purging the destination dir, as it just increases work
	# file delete -force "$synctarget/$release_target"
	
	catch {
		file mkdir "$synctarget/$release_target"
	}
	
	file delete -force "$synctarget/decent"
	file link "$synctarget/decent" "$synctarget/$release_target"

	set files_copied [make_de1_dir "." [list "$synctarget/$release_target"]]

	if {$files_copied != 0} {

		file delete -force "$desktoptarget/osx/decent_osx.zip"
		file delete -force "$desktoptarget/win32/decent_win.zip"
		file delete -force "$desktoptarget/linux/decent_linux.zip"
		file delete -force "$desktoptarget/source/decent_source.zip"

		puts "Making OSX app"
		cd "$miscdir/desktop_app/osx"
		exec zip -u -x "*CVS*" -x ".DS_Store" -r "$desktoptarget/osx/decent_osx.zip" Decent.app 

		puts "Making Win32 app"
		cd "$miscdir/desktop_app/win32"
		exec zip -u -x "*CVS*" -x ".DS_Store" -r "$desktoptarget/win32/decent_win.zip" ./

		puts "Making Linux app"
		cd "$miscdir/desktop_app/linux"
		file attributes "undroidwish/undroidwish-linux32" -permission 0755
		file attributes "undroidwish/undroidwish-linux64" -permission 0755
		file attributes "undroidwish/undroidwish-raspberry" -permission 0755
		file attributes "undroidwish/undroidwish-wayland64" -permission 0755

		cd "$miscdir/desktop_app/"
		file delete -force "$miscdir/desktop_app/decent"
		file link "$miscdir/desktop_app/decent" "$miscdir/desktop_app/linux"
		exec zip -x "*CVS*" -x ".DS_Store" -r "$desktoptarget/linux/decent_linux.zip" decent

		puts "Making source zip"
		cd "$synctarget"
		exec zip -x "*CVS*" -x ".DS_Store" -r "$desktoptarget/source/decent_source.zip" $release_target
		#exec zip -x "*CVS*" -x ".DS_Store" -r "$desktoptarget/source/decent_source_beta.zip" de1beta
		#exec zip -x "*CVS*" -x ".DS_Store" -r "$desktoptarget/source/decent_source_stable.zip" de1plus
	}

} else {
	#skin_convert_all
	make_de1_dir "." [list "$synctarget/$release_target"]

}

file delete "$miscdir/desktop_app/linux/src"
file delete "$miscdir/osx/Decent.app/Contents/Resources/de1plus"
file delete "$miscdir/win32/src"

puts "Success"
exit



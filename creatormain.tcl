#!/usr/local/bin/tclsh

package provide de1_creatormain 1.0

package require de1_vars 
package require de1_gui 
package require de1_binary
package require de1_utils 
package require de1_machine

##############################




proc setup_images_for_other_pages {} {
	#puts "setup_images_for_other_pages"

	global screen_size_width
	global screen_size_height

	#global page_images


#		"espresso_2" "[skin_directory]/espresso_2.png" 
#		"steam_2" "[skin_directory]/steam_2.png" 
	array set page_images [list \
		"off" "[skin_directory]/espresso_1.png" \
		"espresso" "[skin_directory]/espresso_2.png" \
		"espresso_1" "[skin_directory]/espresso_1.png" \
		"espresso_3" "[skin_directory]/espresso_3.png" \
		"steam" "[skin_directory]/steam_2.png" \
		"steam_1" "[skin_directory]/steam_1.png" \
		"steam_3" "[skin_directory]/steam_3.png" \
		"water" "[skin_directory]/water_2.png" \
		"water_1" "[skin_directory]/water_1.png" \
		"water_3" "[skin_directory]/water_3.png" \
		"preheat_1" "[skin_directory]/preheat_1.png" \
		"preheat_2" "[skin_directory]/preheat_2.png" \
		"preheat_3" "[skin_directory]/preheat_3.png" \
		"preheat_4" "[skin_directory]/preheat_4.png" \
		"settings" "[skin_directory]/settings_on.png" \
		"sleep" "[skin_directory]/sleep.jpg" \
		"tankfilling" "[skin_directory]/filling_tank.jpg" \
		"tankempty" "[skin_directory]/fill_tank.jpg" \
		"saver" [random_saver_file] \
	]

	# load each of the PNGs that get displayed for each espresso machine achivity
	foreach {name pngfilename} [array get page_images] {
		if {[file exists $pngfilename] != 1} {
			puts "WARNING, skin file not found: $pngfilename"
		} else {
			#puts "info on $pngfilename [file size $pngfilename]"
		}
		image create photo $name -file $pngfilename
		.can create image {0 0} -anchor nw -image $name  -tag $name -state hidden
	}

	# debug log, will be invisible in release mode
	.can create text 10 10 -text "" -anchor nw -tag .t -fill #000000 -font Helv_4 -width 1000

	# set up the rectangles that define the finger tap zones and the associated command for each 
	source "[skin_directory]/skin.tcl"

}


proc de1_creator_ui_startup {} {
	return [ui_startup]
}


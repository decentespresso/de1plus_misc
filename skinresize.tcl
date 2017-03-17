#!/usr/local/bin/tclsh

source pkgIndex.tcl
package require de1_utils
package require de1_vars

foreach d [lsort -increasing [skin_directories]] {
	skin_convert "[homedir]/skins/$d/2560x1600"
}

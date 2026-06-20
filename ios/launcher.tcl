# iWish iOS-DEVICE de1app launcher -- THIN bootstrap.
# de1app runs directly from the READ-ONLY app bundle. All platform behaviour
# lives in the de1app source tree (/d/admin/code/de1app/de1plus):
#   - de1app.tcl detects iWish via `borg platform` (sets ::iwish / ::ios) and,
#     when ::ios, redirects the writable data root to ~/Documents/Decent and
#     seeds defaults there (the old whole-tree first-run copy is gone).
#   - utils.tcl installs the iOS exit/hardexit handler (ios_install_hardexit).
# This launcher only does what MUST happen before Tcl can source de1app:
# set the script-library paths and the native-extension auto_path, then source.
set _docs [file normalize ~/Documents]
catch {file mkdir $_docs}
set ::_log [open [file join $_docs de1_launch.log] w]; fconfigure $::_log -buffering none
proc L {m} { catch {puts $::_log $m} }
L "iWish device launcher: tcl=[info patchlevel]"

set bundle [file dirname [info nameofexecutable]]
L "bundle=$bundle"

# On a real device there is no TCL_LIBRARY env, so Tcl's init.tcl aborts (auto_path,
# the min/max mathfuncs, and the unknown/auto_load/package handlers never get set
# up). Point at the bundled script libraries and re-source init.tcl (idempotent).
if {![info exists ::tcl_library] || ![file isdirectory $::tcl_library]} { set ::tcl_library [file join $bundle lib tcl8.6] }
if {![info exists ::tk_library]  || ![file isdirectory $::tk_library]}  { set ::tk_library  [file join $bundle lib tk8.6] }
if {[catch {uplevel #0 [list source [file join $::tcl_library init.tcl]]} _ie]} { L "init.tcl re-source err: $_ie" }
if {$::tk_library ni $::auto_path} { lappend ::auto_path $::tk_library }

# Native-extension battery dir (read-only, from the bundle). de1app.tcl does
# `package require Borg` itself, but needs it on the auto_path to find it.
set bat [file join $bundle lib-batteries]
lappend auto_path $bat
foreach d [glob -nocomplain [file join $bat *]] { if {[file isdirectory $d]} { lappend auto_path $d } }
foreach {p v} {itcl ITCL_LIBRARY itk ITK_LIBRARY tktreectrl TREECTRL_LIBRARY vu VU_LIBRARY} {
    if {[file isdirectory [file join $bat $p]]} { set ::env($v) [file join $bat $p] }
}
if {[file isdirectory [file join $bat tktreectrl]]} { set ::treectrl_library [file join $bat tktreectrl] }

cd [file join $bundle de1plus]
encoding system utf-8
L "sourcing de1plus.tcl from bundle"
if {[catch {uplevel #0 [list source [file join $bundle de1plus de1plus.tcl]]} e]} {
    L "DE1 ERROR: $e"; L "--- errorInfo ---"; L $::errorInfo
} else { L "de1plus.tcl sourced ok" }
L "launcher done; event loop"

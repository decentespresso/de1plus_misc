set ::skindebug 1

# labels for PREHEAT tab on
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 405 100 -text [translate "PRE-HEAT CUP"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 1035 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 1665 100 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "preheat_1 preheat_2 preheat_3 preheat_4" 2290 100 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for ESPRESSO tab on
add_de1_text "off espresso espresso_1 espresso_3" 405 100 -text [translate "PRE-HEAT CUP"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "off espresso  espresso_1 espresso_3" 1035 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off espresso espresso_1 espresso_3" 1665 100 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "off espresso espresso_1 espresso_3" 2290 100 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for STEAM tab on
add_de1_text "steam steam_1 steam_3" 405 100 -text [translate "PRE-HEAT CUP"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "steam steam_1 steam_3" 1035 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "steam steam_1 steam_3" 1665 100 -text [translate "STEAM"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam steam_1 steam_3" 2290 100 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 

# labels for HOT WATER tab on
add_de1_text "water water_1 water_3" 405 100 -text [translate "PRE-HEAT CUP"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "water water_1 water_3" 1035 100 -text [translate "ESPRESSO"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "water water_1 water_3" 1665 100 -text [translate "STEAM"] -font Helv_10_bold -fill "#5a5d75" -anchor "center" 
add_de1_text "water water_1 water_3" 2290 100 -text [translate "HOT WATER"] -font Helv_10_bold -fill "#2d3046" -anchor "center" 

# buttons for moving between tabs, available at all times that the espresso machine is not doing something hot
add_de1_button "off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4" {say [translate {pre-heat}] $::settings(sound_button_out); set_next_page off preheat_1; page_show preheat_1} 0 0 641 188
add_de1_button "off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4" {say [translate {espresso}] $::settings(sound_button_out); set_next_page off espresso_1; page_show espresso_1} 642 0 1277 188
add_de1_button "off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4" {say [translate {steam}] $::settings(sound_button_out); set_next_page off steam_1; page_show steam_1} 1278 0 1904 188
add_de1_button "off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4" {say [translate {water}] $::settings(sound_button_out); set_next_page off water_1; page_show water_1} 1905 0 2560 188

# when the espresso machine is doing something, the top tabs have to first stop that function, then the tab can change
add_de1_button "preheat_2 steam water espresso" {say [translate {pre-heat}] $::settings(sound_button_out);set_next_page off preheat_1; start_idle} 0 0 641 188
add_de1_button "preheat_2 steam water espresso" {say [translate {espresso}] $::settings(sound_button_out);set_next_page off espresso_1; start_idle} 642 0 1277 188
add_de1_button "preheat_2 steam water espresso" {say [translate {steam}] $::settings(sound_button_out);set_next_page off steam_1; start_idle} 1278 0 1904 188
add_de1_button "preheat_2 steam water espresso" {say [translate {water}] $::settings(sound_button_out);set_next_page off water_1; start_idle} 1905 0 2560 188


# save/load/clear buttons
add_de1_text "off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4" 1240 1520 -text [translate "Clear"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 
add_de1_text "off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4" 1760 1520 -text [translate "Load"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 
add_de1_text "off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4" 2275 1520 -text [translate "Save"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 




# the "go to sleep" button and the whole-screen button for coming back awake
add_de1_button "off espresso_1 espresso_3 preheat_1 preheat_3 preheat_4 steam_1 steam_3 water_1 water_3 water_4" {say [translate {sleep}] $::settings(sound_button_out); start_sleep} 0 1424 350 1600
add_de1_button "saver" {say [translate {awake}] $::settings(sound_button_out); start_idle} 0 0 2560 1600
add_de1_text "sleep" 2500 1450 -justify right -anchor "ne" -text [translate "Going to sleep"] -font Helv_20_bold -fill "#DDDDDD" 

# temporary exit button to quit app
add_de1_button "off espresso_1 steam_1 water_1 preheat_1" "exit" 351 1424 800 1600

# text on the first espresso page
add_de1_text "off espresso_1" 65 240 -text [translate "1) Preinfuse the coffee puck with hot water"] -font Helv_9 -fill "#5a5d75" -justify "left" -anchor "nw"
add_de1_text "off espresso_1" 65 870 -text [translate "2) Make espresso"] -font Helv_9 -fill "#5a5d75" -justify "left" -anchor "nw"
add_de1_text "off espresso_1" 80 330 -text [translate "PREINFUSE AT:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "off espresso_1" 735 330 -text [translate "STOP PREINFUSION WHEN..."] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_text "espresso" 2200 417 -text [translate "STOP"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "espresso_3" 2200 417 -text [translate "DONE"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off espresso_1" 2205 430 -text [translate "START"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off espresso_1" 2205 765 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 
add_de1_text "espresso_3" 2205 715 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 

add_de1_variable "off espresso_1" 2230 480 -justify right -anchor "ne" -text "" -font Helv_7 -fill "#7f879a" -width 520 -textvariable {[group_head_heater_action_text]} 
add_de1_variable "off espresso_1" 2235 480 -justify left -anchor "nw" -text "" -font Helv_7 -fill "#42465c" -width 520 -textvariable {[group_head_heater_temperature_text]} 


add_de1_variable "off espresso_1" 232 757 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_one_digits $::de1(preinfusion_flow_rate)] [translate "ml/s"]}
add_de1_variable "off espresso_1" 490 490 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_one_digits $::de1(preinfusion_temperature)] [translate "ºC"]}
add_de1_variable "off espresso_1" 835 757 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_one_digits $::de1(preinfusion_stop_flow_rate)] [translate "ml/s"]}
add_de1_variable "off espresso_1" 1132 757 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_one_digits $::de1(preinfusion_stop_pressure)] [translate "bar"]}

add_de1_variable "off espresso_1" 1423 757 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_one_digits $::de1(preinfusion_stop_volumetric)] [translate "ml"]}
add_de1_variable "off espresso_1" 1717 757 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_one_digits $::de1(preinfusion_stop_timeout)][translate "s"]}


#add_de1_text "off espresso_1" 490 490 -text [translate "94ºC"] -font Helv_9_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off espresso_1" 232 703  -text [translate "FLOW RATE"] -font Helv_7 -fill "#7f879a" -anchor "center" 
add_de1_text "off espresso_1" 490 432 -text [translate "TEMP"] -font Helv_7 -fill "#7f879a" -anchor "center" 

add_de1_text "off espresso_1" 835 670 -text [translate "FLOW RATE SLOWS TO"] -font Helv_7 -fill "#7f879a" -anchor "center"  -width 250 -justify center
#add_de1_text "off espresso_1" 835 757 -text [translate "1.5 ml/s"] -font Helv_9_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off espresso_1" 980 722 -text [translate "OR"] -font Helv_7 -fill "#7f879a" -anchor "center"

add_de1_text "off espresso_1" 1132 670 -text [translate "PRESSURE GOES OVER"] -font Helv_7 -fill "#7f879a" -anchor "center"  -width 250 -justify center
#add_de1_text "off espresso_1" 1132 757 -text [translate "1.2 bar"] -font Helv_9_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off espresso_1" 1280 722 -text [translate "OR"] -font Helv_7 -fill "#7f879a" -anchor "center"

add_de1_text "off espresso_1" 1423 670 -text [translate "WATER REACHES"] -font Helv_7 -fill "#7f879a" -anchor "center"  -width 250 -justify center
#add_de1_text "off espresso_1" 1423 757 -text [translate "45 ml"] -font Helv_9_bold -fill "#2d3046" -anchor "center" 
add_de1_text "off espresso_1" 1570 722 -text [translate "OR"] -font Helv_7 -fill "#7f879a" -anchor "center"

add_de1_text "off espresso_1" 1717 670 -text [translate "TIME-OUT"] -font Helv_7 -fill "#7f879a" -anchor "center"  -width 250 -justify center
#add_de1_text "off espresso_1" 1717 757 -text [translate "20s"] -font Helv_9_bold -fill "#2d3046" -anchor "center" 

# the espresso recipe steps
add_de1_text "off espresso_1" 76 957 -text [espresso_frame_title 1] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width 760
add_de1_text "off espresso_1" 76 997 -text [espresso_frame_description 1] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width 760 -justify left

add_de1_text "off espresso_1" 76 1174 -text [espresso_frame_title 2] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width 760
add_de1_text "off espresso_1" 76 1214 -text [espresso_frame_description 2] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width 760 -justify left

add_de1_text "off espresso_1" 893 957 -text [espresso_frame_title 3] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width 760
add_de1_text "off espresso_1" 893 997 -text [espresso_frame_description 3] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width 760 -justify left

add_de1_text "off espresso_1" 893 1174 -text [espresso_frame_title 4] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width 760
add_de1_text "off espresso_1" 893 1214 -text [espresso_frame_description 4] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width 760 -justify left

add_de1_text "off espresso_1" 1710 957 -text [espresso_frame_title 5] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width 760
add_de1_text "off espresso_1" 1710 997 -text [espresso_frame_description 5] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width 760 -justify left

add_de1_text "off espresso_1" 1710 1174 -text [espresso_frame_title 6] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width 760
add_de1_text "off espresso_1" 1710 1214 -text [espresso_frame_description 6] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width 760 -justify left


##########################################################################################################################################################################################################################################################################
# making espresso now

# make and stop espresso button
add_de1_button "off espresso_1" {say [translate {esspresso}] $::settings(sound_button_in);set_next_page off espresso_3; start_espresso} 1900 200 2560 690
add_de1_button "off espresso_1" {say [translate {rinse}] $::settings(sound_button_in);set_next_page off espresso_3; start_espresso} 1900 691 2560 855
add_de1_button "espresso_3" {say [translate {rinse}] $::settings(sound_button_in);set_next_page off espresso_3; start_espresso} 1900 621 2560 855
add_de1_button "off espresso_1" {say [translate {flow rate}] $::settings(sound_button_in);vertical_slider ::de1(preinfusion_flow_rate) 0.1 6 %x %y %x0 %y0 %x1 %y1} 0 320 400 830 "mousemove"
add_de1_button "off espresso_1" {say [translate {temperature}] $::settings(sound_button_in);vertical_slider ::de1(preinfusion_temperature) 80 96 %x %y %x0 %y0 %x1 %y1} 401 320 700 830 "mousemove"
add_de1_button "off espresso_1" {say [translate {temperature}] $::settings(sound_button_in);vertical_slider ::de1(preinfusion_stop_flow_rate) 0.1 6 %x %y %x0 %y0 %x1 %y1} 701 320 980 830 "mousemove"
add_de1_button "off espresso_1" {say [translate {temperature}] $::settings(sound_button_in);vertical_slider ::de1(preinfusion_stop_pressure) 0 6 %x %y %x0 %y0 %x1 %y1} 981 320 1280 830 "mousemove"
add_de1_button "off espresso_1" {say [translate {water reaches}] $::settings(sound_button_in);vertical_slider ::de1(preinfusion_stop_volumetric) 0.1 50 %x %y %x0 %y0 %x1 %y1} 1281 320 1570 830 "mousemove"
add_de1_button "off espresso_1" {say [translate {time-out}] $::settings(sound_button_in);vertical_slider ::de1(preinfusion_stop_timeout) 0 120 %x %y %x0 %y0 %x1 %y1} 1571 320 1870 830 "mousemove"

#add_de1_button "off espresso_1" {say [translate {flow rate}] $::settings(sound_button_in);puts "tap: -width %x -length %y %X %Y %h %w"} 0 320 400 800


# example of creating a widget on the page, to change a variable
#add_de1_widget "off espresso_1" scale 100 300 -from 6.0 -to 0.1 -background #f1f1f1 -borderwidth 1 -bigincrement 0.5 -resolution 0.1 -length 400 -width 50 


add_de1_button "espresso" {say [translate {stop}] $::settings(sound_button_in);set_next_page off espresso_3; start_idle} 1900 201 2560 1400
add_de1_button "espresso" {say [translate {stop}] $::settings(sound_button_in);set_next_page off espresso_3; start_idle} 0 189 2560 200
add_de1_button "espresso" {say [translate {next step}] $::settings(sound_button_in); next_espresso_step } 0 1405 2560 1600
add_de1_button "espresso_3" "set_next_page off espresso_1; page_show espresso_1" 1900 189 2560 620

add_de1_text "espresso" 43 220 -text [translate "PRESSURE:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "espresso" 43 628 -text [translate "FLOW:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"
add_de1_text "espresso" 43 1030 -text [translate "TEMPERATURE:"] -font Helv_7_bold -fill "#7f879a" -justify "left" -anchor "nw"

add_de1_text "espresso" 40 1425 -text [espresso_frame_title 1] -font Helv_6_bold -fill "#2d3046" -anchor "nw" -justify "left" -width 1600
add_de1_text "espresso" 40 1470 -text [espresso_frame_description 1] -font Helv_6 -fill "#7f879a" -anchor "nw"  -width 1600 -justify left

add_de1_text "espresso" 1720 1453 -text [espresso_frame_title 2] -font Helv_6_bold -fill "#5a5d75" -anchor "nw" -justify "left" -width 800
add_de1_text "espresso" 1720 1535 -text [espresso_frame_title 3] -font Helv_6_bold -fill "#5a5d75" -anchor "nw" -justify "left" -width 800

##########################################################################################################################################################################################################################################################################


##########################################################################################################################################################################################################################################################################
# data card displayed during espresso making
add_de1_variable "espresso" 1900 710 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "nw" -textvariable {[string toupper [translate [de1_substate_text]]]} 

add_de1_text "espresso" 1900 785 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width 520

add_de1_text "espresso" 1900 840 -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 2500 840 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[timer][translate "s"]} 

add_de1_text "espresso" 1900 890 -justify right -anchor "nw" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 2500 890 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width 520 -textvariable {[setting_espresso_max_time][translate "s"]} 

add_de1_text "espresso" 1900 940 -justify right -anchor "nw" -text [translate "Preinfusion:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 2500 940 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width 520 -textvariable {[preinfusion_timer][translate "s"]} 

add_de1_text "espresso" 1900 990 -justify right -anchor "nw" -text [translate "Pouring:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 2500 990 -justify left -anchor "ne" -text "" -font Helv_8  -fill "#42465c" -width 520 -textvariable {[pour_timer][translate "s"]} 


add_de1_text "espresso" 1900 1070 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width 520

add_de1_text "espresso" 1900 1120 -justify right -anchor "nw" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 2500 1120 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[pressure_text]} 
add_de1_text "espresso" 1900 1170 -justify right -anchor "nw" -text [translate "Basket temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 2500 1170 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[watertemp_text]} 
add_de1_text "espresso" 1900 1220 -justify right -anchor "nw" -text [translate "Mix temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 2500 1220 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[mixtemp_text]} 


add_de1_text "espresso" 1900 1270 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 2500 1270 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[waterflow_text]} 
add_de1_text "espresso" 1900 1320 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso" 2500 1320 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[watervolume_text]} 

if {$::settings(flight_mode_enable) == 1} {
	add_de1_text "espresso" 1900 1370 -justify right -anchor "nw" -text [translate "Flight mode:"] -font Helv_8 -fill "#7f879a" -width 520
	add_de1_variable "espresso" 2500 1370 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[accelerometer_angle]º} 
}

add_de1_text "espresso_3" 1920 1270 -justify right -anchor "nw" -text [translate "Finished:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "espresso_3" 2460 1270 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[timer][translate "s"]} 

##########################################################################################################################################################################################################################################################################


##########################################################################################################################################################################################################################################################################
# settings for preheating a cup

add_de1_text "preheat_1" 1390 805 -text [translate "START"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "preheat_2" 1390 805 -text [translate "STOP"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "preheat_3" 1390 805 -text [translate "DONE"] -font Helv_20_bold -fill "#7f879a" -anchor "center" 

add_de1_button "preheat_1" {say {[translate {pre-heat cup}]} $::settings(sound_button_in); set_next_page water preheat_2; start_water} 1030 210 2560 1400
add_de1_button "preheat_2" {say [translate {stop}] $::settings(sound_button_in); set_next_page off preheat_3; start_idle} 0 189 2560 1600
add_de1_button "preheat_3" "set_next_page off preheat_1; page_show preheat_1" 0 189 2560 1422

add_de1_button "preheat_1" {say [translate {water volume}] $::settings(sound_button_in);vertical_slider ::de1(preheat_volume) 1 400 %x %y %x0 %y0 %x1 %y1} 0 210 550 1400 "mousemove"
add_de1_button "preheat_1" {say [translate {water temperature}] $::settings(sound_button_in);vertical_slider ::de1(preheat_temperature) 20 96 %x %y %x0 %y0 %x1 %y1} 551 210 1029 1400 "mousemove"

add_de1_text "preheat_1" 70 250 -text [translate "1) How much water and how hot"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width 900
add_de1_text "preheat_1 preheat_2" 1070 250 -text [translate "2) Water will pour into your cup"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width 650
add_de1_text "preheat_1" 1840 250 -text [translate "3) Hot water warms your cup"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width 680
add_de1_text "preheat_3" 1840 250 -text [translate "3) Hot water warms your cup"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width 680

add_de1_variable "preheat_1" 300 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::de1(preheat_volume)] [translate "ml"]}
add_de1_text "preheat_1" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#7f879a" -anchor "center" 
add_de1_variable "preheat_1" 755 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::de1(preheat_temperature)][translate "ºC"]}
add_de1_text "preheat_1" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill "#7f879a" -anchor "center" 

add_de1_variable "preheat_2 preheat_3" 300 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[round_to_integer $::de1(preheat_volume)] [translate "ml"]}
add_de1_text "preheat_2 preheat_3" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 
add_de1_variable "preheat_2 preheat_3" 755 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[round_to_integer $::de1(preheat_temperature)][translate "ºC"]}
add_de1_text "preheat_2 preheat_3" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 


add_de1_text "preheat_3" 1880 1270 -justify right -anchor "nw" -text [translate "Finished:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "preheat_3" 2460 1270 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[timer][translate "s"]} 


##########################################################################################################################################################################################################################################################################

##########################################################################################################################################################################################################################################################################
# settings for dispensing hot water

add_de1_text "water_1" 1390 1270 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 
add_de1_text "water_1" 1390 805 -text [translate "START"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water" 1390 805 -text [translate "STOP"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "water_3" 1390 805 -text [translate "DONE"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_button "water_1" {say {[translate {hot water}]} $::settings(sound_button_in); set_next_page water water; start_water} 1030 210 2560 1100
add_de1_button "water" {say [translate {stop}] $::settings(sound_button_in); set_next_page off water_3 ; start_idle} 0 189 2560 1600
add_de1_button "water_3" {set_next_page off water_1; page_show water_1} 0 189 2560 1422
add_de1_button "water_1" {say {[translate {rinse}]} $::settings(sound_button_in); set_next_page water water; start_water} 1030 1101 1760 1400


add_de1_button "water_1" {say [translate {water volume}] $::settings(sound_button_in);vertical_slider ::de1(water_volume) 1 400 %x %y %x0 %y0 %x1 %y1} 0 210 550 1400 "mousemove"
add_de1_button "water_1" {say [translate {water temperature}] $::settings(sound_button_in);vertical_slider ::de1(water_temperature) 20 96 %x %y %x0 %y0 %x1 %y1} 551 210 1029 1400 "mousemove"

#add_de1_text "water_1" 70 250 -text [translate "1) Choose: how much water and how hot"] -font Helv_10 -fill "#5a5d75" -anchor "nw" -width 900
add_de1_text "water_1" 1070 250 -text [translate "2) Water will pour into your cup"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width 650
add_de1_text "water" 70 250 -text [translate "1) How much water and how hot"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width 900

add_de1_variable "water_1" 300 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center"  -textvariable {[round_to_integer $::de1(water_volume)] [translate "ml"]}
add_de1_text "water_1" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#7f879a" -anchor "center" 
add_de1_variable "water_1" 755 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::de1(water_temperature)][translate "ºC"]}
add_de1_text "water_1" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill "#7f879a" -anchor "center" 

add_de1_variable "water" 300 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center"  -textvariable {[round_to_integer $::de1(water_volume)] [translate "ml"]}
add_de1_text "water" 300 1300  -text [translate "VOLUME"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 
add_de1_variable "water" 755 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[round_to_integer $::de1(water_temperature)][translate "ºC"]}
add_de1_text "water" 755 1300 -text [translate "TEMP"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 

# data card
add_de1_text "water" 1100 280 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width 520
add_de1_text "water" 1100 330 -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 1720 330 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width 520 -text "" -textvariable {[water_timer][translate "s"]} 
add_de1_text "water" 1100 380 -justify right -anchor "nw" -text [translate "Auto off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 1720 380 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width 520 -text "" -textvariable {[setting_water_max_time][translate "s"]} 

add_de1_text "water" 1100 1150 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width 520

add_de1_text "water" 1100 1200 -justify right -anchor "nw" -text [translate "Water temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 1720 1200 -justify left -anchor "ne" -font Helv_8 -fill "#42465c" -width 520 -text "" -textvariable {[watertemp_text]} 


add_de1_text "water" 1100 1250 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 1720 1250 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[waterflow_text]} 
add_de1_text "water" 1100 1300 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water" 1720 1300 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[watervolume_text]} 


add_de1_text "water_3" 1110 1270 -justify right -anchor "nw" -text [translate "Finished:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "water_3" 1670 1270 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[timer][translate "s"]} 



##########################################################################################################################################################################################################################################################################



##########################################################################################################################################################################################################################################################################
# settings for steam

add_de1_text "steam_1" 1390 1270 -text [translate "Rinse"] -font Helv_10_bold -fill "#eae9e9" -anchor "center" 
add_de1_text "steam_1" 1390 805 -text [translate "START"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam" 1390 805 -text [translate "STOP"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam_2" 1390 805 -text [translate "DONE"] -font Helv_20_bold -fill "#2d3046" -anchor "center" 
add_de1_text "steam_3" 1390 805 -text [translate "DONE"] -font Helv_20_bold -fill "#7f879a" -anchor "center" 
add_de1_button "steam_1" {say {[translate {steam}]} $::settings(sound_button_in); start_steam} 1030 210 2560 1100
add_de1_button "steam_1" {say {[translate {rinse}]} $::settings(sound_button_in); start_steam} 1030 1101 1760 1400
add_de1_button "steam" {say [translate {stop}] $::settings(sound_button_in); set_next_page off steam_3; start_idle} 0 189 2560 1600
add_de1_button "steam_3" {say {[translate {steam}]} $::settings(sound_button_in); set_next_page off steam_1; page_show steam_1} 0 189 2560 1422

add_de1_variable "steam_1" 1410 855 -justify right -anchor "ne" -text "" -font Helv_7 -fill "#7f879a" -width 520 -textvariable {[steam_heater_action_text]} 
add_de1_variable "steam_1" 1415 855 -justify left -anchor "nw" -font Helv_7 -text "" -fill "#42465c" -width 520 -textvariable {[setting_steam_temperature_text]} 



add_de1_button "steam_1" {say [translate {steam temperature}] $::settings(sound_button_in);vertical_slider ::de1(steam_temperature) 140 170 %x %y %x0 %y0 %x1 %y1} 0 210 450 1400 "mousemove"
add_de1_button "steam_1" {say [translate {steam time-out}] $::settings(sound_button_in);vertical_slider ::de1(steam_timeout) 1 500 %x %y %x0 %y0 %x1 %y1} 451 210 1029 1400 "mousemove"

add_de1_text "steam_1" 70 250 -text [translate "1) Steam temperature and auto-off time"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width 900
add_de1_text "steam_1" 1070 250 -text [translate "2) Steam will start"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width 650
add_de1_text "steam_1" 1840 250 -text [translate "3) Pour amazing latte art"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width 680
add_de1_text "steam_3" 1840 250 -text [translate "3) Pour amazing latte art"] -font Helv_9 -fill "#5a5d75" -anchor "nw" -width 680
add_de1_text "steam" 70 250 -text [translate "1) Steam temperature and auto-off time"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width 900
add_de1_text "steam" 1840 250 -text [translate "3) Make amazing latte art"] -font Helv_9 -fill "#b1b9cd" -anchor "nw" -width 680

add_de1_variable "steam_1" 300 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_integer $::de1(steam_temperature)][translate "ºC"]}
add_de1_text "steam_1" 300 1300  -text [translate "TEMP"] -font Helv_7 -fill "#7f879a" -anchor "center" 
add_de1_variable "steam_1" 720 1250 -text "" -font Helv_10_bold -fill "#2d3046" -anchor "center"  -textvariable {[round_to_integer $::de1(steam_timeout)][translate "s"]}
add_de1_text "steam_1" 720 1300 -text [translate "AUTO-OFF"] -font Helv_7 -fill "#7f879a" -anchor "center" 


#add_de1_variable "off espresso_1" 1717 757 -text "" -font Helv_9_bold -fill "#2d3046" -anchor "center" -textvariable {[round_to_one_digits $::de1(preinfusion_stop_timeout)][translate "s"]}

add_de1_variable "steam" 300 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center" -textvariable {[round_to_integer $::de1(steam_temperature)][translate "ºC"]}
add_de1_text "steam" 300 1300  -text [translate "TEMP"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 
add_de1_variable "steam" 720 1250 -text "" -font Helv_10_bold -fill "#7f879a" -anchor "center"  -textvariable {[round_to_integer $::de1(steam_timeout)][translate "s"]}
add_de1_text "steam" 720 1300 -text [translate "AUTO-OFF"] -font Helv_7 -fill "#b1b9cd" -anchor "center" 

# variables to display during steam
add_de1_text "steam" 1100 280 -justify right -anchor "nw" -text [translate "Time"] -font Helv_8_bold -fill "#5a5d75" -width 520

add_de1_text "steam" 1100 330  -justify right -anchor "nw" -text [translate "Elapsed:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 1720 330 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[steam_timer][translate "s"]} 
add_de1_text "steam" 1100 380 -justify right -anchor "nw" -text [translate "Auto-Off:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 1720 380 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[setting_steam_max_time][translate "s"]} 

add_de1_text "steam" 1100 1100 -justify right -anchor "nw" -text [translate "Characteristics"] -font Helv_8_bold -fill "#5a5d75" -width 520
add_de1_text "steam" 1100 1150 -justify right -anchor "nw" -text [translate "Temp:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 1720 1150 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[steamtemp_text]} 
add_de1_text "steam" 1100 1200 -justify right -anchor "nw" -text [translate "Pressure:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 1720 1200 -justify left -anchor "ne" -font Helv_8 -text "" -fill "#42465c" -width 520 -textvariable {[pressure_text]} 

add_de1_text "steam" 1100 1250 -justify right -anchor "nw" -text [translate "Flow rate:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 1720 1250 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[waterflow_text]} 
add_de1_text "steam" 1100 1300 -justify right -anchor "nw" -text [translate "Volume:"] -font Helv_8 -fill "#7f879a" -width 520
add_de1_variable "steam" 1720 1300 -justify left -anchor "ne" -text "" -font Helv_8 -fill "#42465c" -width 520 -textvariable {[watervolume_text]} 



##########################################################################################################################################################################################################################################################################

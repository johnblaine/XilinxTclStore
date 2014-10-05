# tclapp/xilinx/designutils/split_LUT6_2.tcl
package require Vivado 1.2014.1

namespace eval ::tclapp::xilinx::designutils {
    namespace export split_LUT6_2
}


proc ::tclapp::xilinx::designutils::split_LUT6_2 {} {

    # Summary: This script breaks up all LUT6_2s in a design into two independent LUT5/6s

    # Argument Usage:

    # Return Value:
    # TCL_OK is returned with result set to a string

    # Categories: xilinxtclstore, netlistutils

	puts "SCRIPT INFO: This script removes LUT6_2s and replaces them with LUT5 and LUT6 separated primitives"
	
	#pre script design information
	set LUT5s [llength [get_cells -hierarchical -filter { PRIMITIVE_TYPE == LUT.others.LUT5 } ]]
	set LUT6s [llength [get_cells -hierarchical -filter { PRIMITIVE_TYPE == LUT.others.LUT6 } ]]
	set LUT6_2s [llength [get_cells -hierarchical -filter { PRIMITIVE_TYPE == LUT.others.LUT6_2 } ]]
	
	#puts "SCRIPT DEBUG: Found $LUT6s LUT6s"
	#puts "SCRIPT DEBUG: Found $LUT5s LUT5s"
	
	puts "SCRIPT INFO: Found $LUT6_2s LUT6_2s ...now will begin to process them..."
	set processed 0
	set percent_done_prev 0
	
	set cells [get_cells -hierarchical -filter { PRIMITIVE_TYPE == LUT.others.LUT6_2 } ]
	foreach cell $cells {
		set nets [get_nets -of $cell]
		if {[llength $nets] == 8} {
			set data($cell,I0) [lindex $nets 0]
			set data($cell,I1) [lindex $nets 1]
			set data($cell,I2) [lindex $nets 2]
			set data($cell,I3) [lindex $nets 3]
			set data($cell,I4) [lindex $nets 4]
			set data($cell,I5) [lindex $nets 5]
			set data($cell,O5) [lindex $nets 6]
			set data($cell,O6) [lindex $nets 7]
		} else {
			puts "SCRIPT ERROR: Configuration of cell $cell does not have 8 nets. For a fully connected LUT6_2 this should be the case"
		}
		
	# create and connect up the LUT5 LUT6 pins
	create_cell -reference LUT5 ${cell}_LUT5
	create_cell -reference LUT6 ${cell}_LUT6
	
	foreach pin [list I0 I1 I2 I3 I4] {
		connect_net -net [get_nets $data($cell,$pin)] -objects [list [get_pins ${cell}_LUT5/${pin}] [get_pins ${cell}_LUT6/${pin}]]
	}
	# connect up the odd LUT5 + LUT6 pins
	connect_net -net [get_nets $data($cell,O5)] -objects [get_pins ${cell}_LUT5/O]
	connect_net -net [get_nets $data($cell,I5)] -objects [get_pins ${cell}_LUT6/I5]
	connect_net -net [get_nets $data($cell,O6)] -objects [get_pins ${cell}_LUT6/O]
	
	# set the init attributes
	set INIT [get_property INIT $cell]
	set INIT_format [string range $INIT 0 3]
	set LUT5_start [expr ([string length $INIT]/2) + 2]
	set LUT5_INIT [string range $INIT $LUT5_start end]
	set LUT5_INIT ${INIT_format}${LUT5_INIT}
	set_property INIT $LUT5_INIT [get_cells ${cell}_LUT5]
	set_property INIT $INIT [get_cells ${cell}_LUT6]
	
	# generate statistics and something to say the script is alive
	incr processed
	set percent_done [expr ($processed/${LUT6_2s}.0)*100]
	set percent_idx [string first . $percent_done]
	set percent_done [string range $percent_done 0 $percent_idx-1]
	if {$percent_done > $percent_done_prev} {
		puts -nonewline "."
		set percent_done_prev $percent_done
	}
	
	}
	
	puts "\nSCRIPT INFO: Script converted $processed LUT6_2s to $processed LUT5s and $processed LUT6s"
	
	#now remove all the old LUTs
	remove_cell [get_cells -hierarchical -filter { PRIMITIVE_TYPE == LUT.others.LUT6_2 } ]
	
	# run a final DRC check
	set LUT5s_new [llength [get_cells -hierarchical -filter { PRIMITIVE_TYPE == LUT.others.LUT5 } ]]
	set LUT6s_new [llength [get_cells -hierarchical -filter { PRIMITIVE_TYPE == LUT.others.LUT6 } ]]
	set LUT6_2s_new [llength [get_cells -quiet -hierarchical -filter { PRIMITIVE_TYPE == LUT.others.LUT6_2 } ]]
# COMMENT: When using get_cells vivado will count LUT6_2, and also include the number in LUT6 and LUT5. Therefore there is no primitive count increase"
#	if {$LUT5s_new != [expr $LUT5s + $LUT6_2s]} {
#		puts "SCRIPT ERROR: Expecting [expr $LUT5s + $LUT6_2s] LUT5 primitives  but got $LUT5s_new"
#	} 
#	if {$LUT6s_new != [expr $LUT6s + $LUT6_2s]} {
#		puts "SCRIPT ERROR: Expecting [expr $LUT6s + $LUT6_2s] LUT6 primitives but got $LUT6s_new"
#	}
	if {$LUT6_2s_new != 0} {
		puts "SCRIPT ERROR: Expecting 0 LUT6_2 primitives but got $LUT6_2s_new"
	}
}

#puts "split_LUT6_2: [time {set result [::tclapp::xilinx::designutils::split_LUT6_2]}]"

# Set the File Directory to the current directory location of the script
set file_dir [file normalize [file dirname [info script]]]

# Set the Xilinx Tcl App Store Repository to the current repository location
puts "== Unit Test directory: $file_dir"

# Set the Name to the name of the script
set name [file rootname [file tail [info script]]]

read_checkpoint $file_dir/src/split_LUT6_2/split_LUT6_2_test.dcp
link_design

if {[catch { ::tclapp::xilinx::designutils::split_LUT6_2 } catchErrorString]} {
    close_project
    error [format " -E- Unit test $name failed: %s" $catchErrorString]   
}

close_project

return 0
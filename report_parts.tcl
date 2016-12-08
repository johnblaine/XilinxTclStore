proc ::tclapp::xilinx::designutils::report_parts { {pattern *} } {
  # Summary : Report all the available parts that match a pattern

  # Argument Usage:
  # [pattern = *] : Pattern for part names

  # Return Value:
  # 0
  
  # Categories: xilinxtclstore, designutils

  # Initialize the table object
  set table [::tclapp::xilinx::designutils::prettyTable create {Summary of all parts}]
  set table1 [::tclapp::xilinx::designutils::prettyTable create {SLR based information}]
  $table header { PART ARCH LUT SLICE DSP RAM MMCM PCI GB IO PACK }
  $table1 header { PART ARCH SLRS LUT SLICE DSP RAM MMCM }
  set slr_table 0
  
  foreach part [lsort -dictionary [get_parts -quiet $pattern]] {
    set arch [get_property -quiet ARCHITECTURE $part]
    set numRAM [get_property -quiet BLOCK_RAMS $part]
    set numIO [get_property -quiet AVAILABLE_IOBS $part]
    set numDSP [get_property -quiet DSP $part]
    set numLUT [get_property -quiet LUT_ELEMENTS $part]
    set numMMCM [get_property -quiet MMCM $part]
    set numSLICE [get_property -quiet SLICES $part]
    set numPCI [get_property -quiet PCI_BUSES $part]
    set PACKAGE [get_property -quiet PACKAGE $part]
    set numGB [get_property -quiet GB_TRANSCEIVERS $part]
    set numFF [get_property -quiet FLIPFLOPS $part]
    $table addrow [list $part $arch $numLUT $numSLICE $numDSP $numRAM $numMMCM $numPCI $numGB $numIO $PACKAGE ]
    set SLRs [get_property -quiet SLRS $part]
    if {$SLRs > 1} {
        set slr_table 1
        set numLUT_slr   [expr $numLUT/$SLRs]
        set numSLICE_slr [expr $numSLICE/$SLRs]
        set numDSP_slr   [expr $numDSP/$SLRs]
        set numRAM_slr   [expr $numRAM/$SLRs]
        set numMMCM_slr  [expr $numMMCM/$SLRs]
        $table1 addrow [list $part $arch $SLRs $numLUT_slr $numSLICE_slr $numDSP_slr $numRAM_slr $numMMCM_slr]
    }
  }
  
  puts [$table print]\n
  if {$slr_table == 1} {
    puts [$table1 print]\n
  }
  # Destroy the table objects to free memory
  catch {$table destroy}
  catch {$table1 destroy}
  return 0
}
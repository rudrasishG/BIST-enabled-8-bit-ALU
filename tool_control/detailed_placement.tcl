#!/usr/bin/env openroad

puts "=========================================="
puts "   BIST ALU - Detailed Placement"
puts "=========================================="

read_lef sky130.tlef
read_lef ~/pdks/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef
read_liberty ~/pdks/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_def physical_design/results/placement_global.def
puts "  ✓ Global placement loaded"

read_sdc netlist/test.sdc

# Detailed placement - legalizes cells onto rows
puts "\n Running detailed placement..."
detailed_placement

puts "  ✓ Detailed placement done"

# Verify no placement violations
puts "\n Checking placement legality..."
check_placement -verbose

report_design_area

# Post-placement timing
puts "\n Post-placement timing..."
estimate_parasitics -placement
report_wns
report_tns

write_def physical_design/results/placement_detailed.def
puts "\n  ✓ Written: physical_design/results/placement_detailed.def"
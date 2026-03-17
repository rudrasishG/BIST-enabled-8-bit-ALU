#!/usr/bin/env openroad

puts "=========================================="
puts "   BIST ALU - Routing"
puts "=========================================="

read_lef sky130.tlef
read_lef ~/pdks/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef
read_liberty ~/pdks/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_def physical_design/results/cts.def
puts "  ✓ CTS DEF loaded"

read_sdc netlist/test.sdc

# Fix: move power/ground nets to SPECIALNETS
puts "\n Fixing power net classification..."
set block [ord::get_db_block]
foreach net_name {VDD VSS one_} {
    set net [$block findNet $net_name]
    if {$net != "NULL"} {
        $net setSpecial
        puts "  ✓ $net_name marked as special"
    } else {
        puts "  - $net_name not found, skipping"
    }
}

# Global routing
puts "\n Running global routing..."
global_route \
    -guide_file physical_design/results/route.guide \
    -verbose

puts "  ✓ Global routing done"

# Detailed routing
puts "\n Running detailed routing..."
detailed_route \
    -output_drc physical_design/results/drc.rpt \
    -output_maze physical_design/results/maze.log \
    -verbose 1

puts "  ✓ Detailed routing done"

# Post-route timing
puts "\n Post-route timing..."
estimate_parasitics -global_routing
report_wns
report_tns
report_design_area

write_def physical_design/results/routed.def
puts "\n  ✓ Written: physical_design/results/routed.def"
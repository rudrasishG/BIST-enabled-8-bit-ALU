#!/usr/bin/env openroad
read_lef sky130.tlef
read_lef ~/pdks/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef

read_liberty ~/pdks/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_verilog netlist/bist_top_netlist2.v
link_design bist_alu_top

puts "\n=== Design Statistics ==="

# Instance count (report_instance_count doesn't exist in OpenROAD)
set block [ord::get_db_block]
set insts [$block getInsts]
puts "Instance count : [llength $insts]"

# Area (this one is valid)
report_design_area

# Ports (this one is valid)
report_checks -unconstrained -path_count 0
report_ports
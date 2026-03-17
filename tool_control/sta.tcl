# Read liberty
read_liberty sky130.lib

# Read synthesized netlist
read_verilog netlist/bist_top_netlist.v

# Link design
link_design bist_alu_top

# Read constraints
read_sdc netlist/test.sdc

# Propagate clocks
set_propagated_clock [all_clocks]

#dynamic switching activity
set_power_activity -global -activity 0.1

puts "========== MAX DELAY =========="
report_checks -path_delay max -digits 4

puts "========== MIN DELAY =========="
report_checks -path_delay min -digits 4

puts "========== WNS =========="
report_wns

puts "========== TNS =========="
report_tns


puts "========== POWER ========="
report_power

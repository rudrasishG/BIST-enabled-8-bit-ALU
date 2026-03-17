#!/usr/bin/env openroad

puts "=========================================="
puts "   BIST ALU - Global Placement"
puts "=========================================="

# Load libraries
read_lef sky130.tlef
read_lef ~/pdks/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef
read_liberty ~/pdks/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# Load netlist and constraints

# Read floorplan DEF (with pins already placed)
read_def physical_design/results/floorplan.def
puts "  ✓ Floorplan loaded"
#read_verilog netlist/bist_top_netlist2.v
#link_design bist_alu_top
read_sdc netlist/test.sdc
set block [ord::get_db_block]
foreach bterm [$block getBTerms] {
    foreach bpin [$bterm getBPins] {
        $bpin setPlacementStatus "FIRM"
    }
}
# -----------------------------------------------
# Global Placement
# -----------------------------------------------
# Target density 0.65 — gives placer room to spread
# 286 cells in 25600 um² core = ~9.6% actual density
# so placer has plenty of space, no overflow expected
puts "\n Running global placement..."

global_placement \
    -density 0.65 \
    -pad_left 2 \
    -pad_right 2

puts "  ✓ Global placement done"
report_design_area

# -----------------------------------------------
# Basic timing check post-placement
# -----------------------------------------------
puts "\n Post-placement timing (estimated)..."
estimate_parasitics -placement
report_wns
report_tns

# Write result
write_def physical_design/results/placement_global.def
puts "\n  ✓ Written: physical_design/results/placement_global.def"
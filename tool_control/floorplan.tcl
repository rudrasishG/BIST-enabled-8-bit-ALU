#!/usr/bin/env openroad

puts "=========================================="
puts "   BIST ALU - Floorplan Creation"
puts "=========================================="

# Load libraries
puts "\n Loading technology libraries..."
read_lef sky130.tlef
read_lef ~/pdks/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef
read_liberty ~/pdks/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
puts "  ✓ Technology loaded"

# Load netlist
puts "\n Loading netlist..."
read_verilog netlist/bist_top_netlist2.v
link_design bist_alu_top
puts "  ✓ Design loaded: bist_alu_top"

# Load constraints
puts "\n Loading constraints..."
read_sdc netlist/test.sdc
puts "  ✓ Constraints loaded"

# Create floorplan
puts "\n Creating floorplan..."
puts "  Die:  180 x 180 um"
puts "  Core: 160 x 160 um"

initialize_floorplan \
    -die_area  "0 0 180 180" \
    -core_area "10 10 170 170" \
    -site unithd

# Generate routing track grid (required before place_pins)
make_tracks
puts "  ✓ Floorplan and tracks created"

# -----------------------------------------------
# Pin placement constraints by functional group
# -----------------------------------------------
# TOP edge   : data inputs a[0:7], b[0:7]
# LEFT edge  : control inputs (clk, reset, op, bist_*, mode)
# RIGHT edge : data outputs y[0:7]
# BOTTOM edge: status outputs bist_done, bist_pass

puts "\n Assigning pin groups to sides..."

# TOP - data inputs a and b (vertical pins on met4)
set_io_pin_constraint \
    -pin_names {a[0] a[1] a[2] a[3] a[4] a[5] a[6] a[7]
                b[0] b[1] b[2] b[3] b[4] b[5] b[6] b[7]} \
    -region top:*

# LEFT - all control and clock inputs (horizontal pins on met3)
set_io_pin_constraint \
    -pin_names {clk reset
                op[0] op[1] op[2]
                bist_start bist_power_enable
                normal_enable power_mode} \
    -region left:*

# RIGHT - data outputs (horizontal pins on met3)
set_io_pin_constraint \
    -pin_names {y[0] y[1] y[2] y[3] y[4] y[5] y[6] y[7]} \
    -region right:*

# BOTTOM - BIST status outputs (vertical pins on met4)
set_io_pin_constraint \
    -pin_names {bist_done bist_pass} \
    -region bottom:*

puts "  ✓ Pin group constraints set"

# Place pins with explicit layer assignment
puts "\n Placing I/O pins..."
place_pins \
    -hor_layers met3 \
    -ver_layers met4 \
    -corner_avoidance 15 \
    -min_distance 5

puts "  ✓ Pins placed"

# Write output
file mkdir physical_design/results
write_def physical_design/results/floorplan.def
puts "\n  ✓ Floorplan written to physical_design/results/floorplan.def"

# Summary
puts "\n=========================================="
puts "   Floorplan Summary"
puts "=========================================="
set block [ord::get_db_block]
puts "  Instances : [llength [$block getInsts]]"
puts "  Pins      : [llength [$block getBTerms]]"
report_design_area
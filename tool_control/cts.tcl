#!/usr/bin/env openroad

puts "=========================================="
puts "   BIST ALU - Clock Tree Synthesis"
puts "=========================================="

read_lef sky130.tlef
read_lef ~/pdks/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lef/sky130_fd_sc_hd.lef
read_liberty ~/pdks/share/pdk/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_def physical_design/results/placement_detailed.def
puts "  ✓ Detailed placement loaded"

read_sdc netlist/test.sdc

# -----------------------------------------------
# Clock Tree Synthesis
# -----------------------------------------------
# clk fans out to 41 flip-flops — needs buffering
puts "\n Running CTS..."

configure_cts_characterization \
    -max_slew 0.75 \
    -max_cap 0.1

clock_tree_synthesis \
    -root_buf sky130_fd_sc_hd__clkbuf_4 \
    -buf_list {sky130_fd_sc_hd__clkbuf_1
               sky130_fd_sc_hd__clkbuf_2
               sky130_fd_sc_hd__clkbuf_4
               sky130_fd_sc_hd__clkbuf_8} \
    -sink_clustering_enable \
    -sink_clustering_size 10 \
    -sink_clustering_max_diameter 50

puts "  ✓ CTS done"

# Legalize CTS-inserted buffers
puts "\n Legalizing CTS buffer placement..."
detailed_placement
puts "  ✓ Post-CTS legalization done"

# Post-CTS timing
puts "\n Post-CTS timing..."
estimate_parasitics -placement
report_clock_skew
report_wns
report_tns

write_def physical_design/results/cts.def
puts "\n  ✓ Written: physical_design/results/cts.def"
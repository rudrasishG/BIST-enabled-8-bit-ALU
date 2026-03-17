create_clock -name clk -period 5 [get_ports clk]

set_clock_uncertainty 0.2 [get_clocks clk]

set_input_delay 1 -clock clk [get_ports {reset bist_start a[*] b[*] op[*] normal_enable power_mode bist_power_enable}]

set_output_delay 1 -clock clk [get_ports {y[*] bist_done bist_pass}]

# Model external load based on sky130 docs
set_load 0.1 [get_ports {y[*] bist_done bist_pass}]

# Async reset commented for now ..might use later if full risc v core
#set_false_path -from [get_ports reset]

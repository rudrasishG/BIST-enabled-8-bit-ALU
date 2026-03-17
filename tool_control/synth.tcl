read_liberty -lib sky130.lib

read_verilog rtl/alu.v
read_verilog rtl/bist_controller.v
read_verilog rtl/misr.v
read_verilog rtl/randgen.v
read_verilog rtl/signature_compare.v
read_verilog rtl/bist_alu_top.v

hierarchy -check -top bist_alu_top

synth -top bist_alu_top -flatten

dfflibmap -liberty sky130.lib

abc -liberty sky130.lib -D 4.5

clean

write_verilog -noattr -noexpr netlist/bist_top_netlist2.v

# Report area
stat -liberty sky130.lib

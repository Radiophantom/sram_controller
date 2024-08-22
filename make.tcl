
vlib vhdl_libs
vcom -work vhdl_libs package_timing.vhd package_utility.vhd mobl_256Kx16.vhd

vlib verilog_libs
vlog -work verilog_libs -L vhdl_libs top_tb.sv

vlib work
vopt -work work -L vhdl_libs -L verilog_libs +acc -o top_tb_opt top_tb
vsim -work work top_tb_opt

#if { ![batch_mode] && [file exists "wave.do"] } {
#  do "wave.do"
#}
#
#run -all


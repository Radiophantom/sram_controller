
sim:
	vsim -c -do make.tcl

clean:
	rm -rf work/
	rm -rf vhdl_libs/
	rm -rf verilog_libs/
	rm -rf transcript

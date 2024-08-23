
proc compile_sram_model {} {
  vlib sram_model_lib
  vcom -work sram_model_lib sram_model/package_timing.vhd sram_model/package_utility.vhd sram_model/mobl_256Kx16.vhd
}

proc compile_rtl {} {
  vlib rtl_lib
  vlog -work rtl_lib -sv -f rtl_files
}

proc compile_tb {} {
  vlib work
  vlog -work work -sv -f tb_files
}

proc simulate {} {
  vopt -work work -L sram_model_lib -L rtl_lib +acc -o top_tb_opt top_tb
  vsim -work work top_tb_opt
  if { ![batch_mode] && [file exists "wave.do"] } {
    do "wave.do"
  }
  run -all
}

compile_sram_model
compile_rtl
compile_tb
simulate

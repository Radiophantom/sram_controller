onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/rst
add wave -noupdate /top_tb/clk
add wave -noupdate -divider {Avalon-MM interface}
add wave -noupdate /top_tb/mem_if/address
add wave -noupdate /top_tb/mem_if/byteenable
add wave -noupdate /top_tb/mem_if/write
add wave -noupdate /top_tb/mem_if/writedata
add wave -noupdate /top_tb/mem_if/read
add wave -noupdate /top_tb/mem_if/readdatavalid
add wave -noupdate /top_tb/mem_if/readdata
add wave -noupdate /top_tb/mem_if/waitrequest
add wave -noupdate -divider {SRAM interface}
add wave -noupdate /top_tb/sram_model/CE1_b
add wave -noupdate /top_tb/sram_model/CE2
add wave -noupdate /top_tb/sram_model/A
add wave -noupdate /top_tb/sram_model/OE_b
add wave -noupdate /top_tb/sram_model/WE_b
add wave -noupdate /top_tb/sram_model/BHE_b
add wave -noupdate /top_tb/sram_model/BLE_b
add wave -noupdate /top_tb/sram_model/DQ
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {205 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {177 ns} {441 ns}

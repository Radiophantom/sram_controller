onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_tb/DUT/CE1_b
add wave -noupdate /top_tb/DUT/CE2
add wave -noupdate /top_tb/DUT/WE_b
add wave -noupdate /top_tb/DUT/OE_b
add wave -noupdate /top_tb/DUT/BHE_b
add wave -noupdate /top_tb/DUT/BLE_b
add wave -noupdate /top_tb/DUT/A
add wave -noupdate /top_tb/DUT/DQ
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3528 ns} 0}
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
WaveRestoreZoom {0 ns} {10500 ns}

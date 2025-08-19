onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /a_mcu_tb/U_0/Basic_Timer/CLK
add wave -noupdate /a_mcu_tb/KEY1
add wave -noupdate /a_mcu_tb/KEY2
add wave -noupdate /a_mcu_tb/KEY3
add wave -noupdate /a_mcu_tb/U_0/Basic_Timer/PWM
add wave -noupdate /a_mcu_tb/U_0/Basic_Timer/BTSSEL
add wave -noupdate -radix decimal /a_mcu_tb/U_0/Basic_Timer/BTCNT
add wave -noupdate /a_mcu_tb/U_0/Basic_Timer/DIV
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3589709561 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 354
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {938352807 ps} {5766886695 ps}

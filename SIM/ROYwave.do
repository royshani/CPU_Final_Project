onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/IO_interface/LEDR
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_1/KEY1
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_1/KEY2
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_1/KEY3
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/CLR_IRQ
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/ControlBus
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/DataBus
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/GIE
add wave -noupdate -radix binary -childformat {{/a_mcu_tb/U_0/IFG(6) -radix binary} {/a_mcu_tb/U_0/IFG(5) -radix binary} {/a_mcu_tb/U_0/IFG(4) -radix binary} {/a_mcu_tb/U_0/IFG(3) -radix binary} {/a_mcu_tb/U_0/IFG(2) -radix binary} {/a_mcu_tb/U_0/IFG(1) -radix binary} {/a_mcu_tb/U_0/IFG(0) -radix binary}} -expand -subitemconfig {/a_mcu_tb/U_0/IFG(6) {-height 15 -radix binary} /a_mcu_tb/U_0/IFG(5) {-height 15 -radix binary} /a_mcu_tb/U_0/IFG(4) {-height 15 -radix binary} /a_mcu_tb/U_0/IFG(3) {-height 15 -radix binary} /a_mcu_tb/U_0/IFG(2) {-height 15 -radix binary} /a_mcu_tb/U_0/IFG(1) {-height 15 -radix binary} /a_mcu_tb/U_0/IFG(0) {-height 15 -radix binary}} /a_mcu_tb/U_0/IFG
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/INTA
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/INTR
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/INTR_Active
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/IntrEn
add wave -noupdate -radix binary /a_mcu_tb/U_0/IntrSrc
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/IRQ_OUT
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/MemReadBus
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/PC
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/TypeReg
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/CPU/EPC
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/CPU/Instruction
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/CPU/HOLD_PC
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/CPU/IntrEn
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/CPU/ISRAddr
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/CPU/jump_address
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/CPU/PC
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/CPU/STATE
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/CPU/Read_ISR_PC
add wave -noupdate /a_mcu_tb/U_0/Basic_Timer/PWM
add wave -noupdate /a_mcu_tb/U_0/Intr_Controller/FIRIFG_type
add wave -noupdate /a_mcu_tb/U_0/div_acc/fifo_count
add wave -noupdate /a_mcu_tb/U_0/div_acc/fifo_count_rd
add wave -noupdate /a_mcu_tb/U_0/div_acc/fifo_count_wr
add wave -noupdate /a_mcu_tb/U_0/div_acc/fifo_memory
add wave -noupdate /a_mcu_tb/U_0/div_acc/fifo_rd_ptr
add wave -noupdate /a_mcu_tb/U_0/div_acc/fifo_wr_ptr
add wave -noupdate /a_mcu_tb/U_0/div_acc/FIFOEMPTY
add wave -noupdate /a_mcu_tb/U_0/div_acc/FIFOEMPTY_flag
add wave -noupdate /a_mcu_tb/U_0/div_acc/FIFOFULL
add wave -noupdate /a_mcu_tb/U_0/div_acc/FIFOFULL_flag
add wave -noupdate /a_mcu_tb/U_0/div_acc/FIFORST
add wave -noupdate /a_mcu_tb/U_0/div_acc/FIFOWEN
add wave -noupdate /a_mcu_tb/U_0/div_acc/fir_pulse
add wave -noupdate -expand /a_mcu_tb/U_0/div_acc/FIRCTL
add wave -noupdate /a_mcu_tb/U_0/div_acc/FIRENA
add wave -noupdate /a_mcu_tb/U_0/div_acc/FIFOREN
add wave -noupdate /a_mcu_tb/U_0/div_acc/FIRIFG
add wave -noupdate /a_mcu_tb/U_0/div_acc/FIRIFG_type
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/div_acc/FIRIN
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/div_acc/FIROUT
add wave -noupdate /a_mcu_tb/U_0/div_acc/firout_ready
add wave -noupdate /a_mcu_tb/U_0/div_acc/FIRRST
add wave -noupdate /a_mcu_tb/U_0/div_acc/processing_active
add wave -noupdate /a_mcu_tb/U_0/div_acc/state_next
add wave -noupdate /a_mcu_tb/U_0/div_acc/state_reg
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/div_acc/x_delay
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/div_acc/x_input
add wave -noupdate /a_mcu_tb/U_0/div_acc/y_counter
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/div_acc/y_output
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/AddressBus
add wave -noupdate /a_mcu_tb/U_0/div_acc/FIRCLK
add wave -noupdate /a_mcu_tb/U_0/div_acc/FIFOCLK
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3990845969 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 292
configure wave -valuecolwidth 100
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
WaveRestoreZoom {3975760614 ps} {4035939387 ps}

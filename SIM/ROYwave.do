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
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/Addr
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/COEF0
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/COEF1
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/COEF2
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/COEF3
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/COEF4
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/COEF5
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/COEF6
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/COEF7
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/coefficients
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/fifo_count
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/fifo_count_rd
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/fifo_count_wr
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/fifo_empty_internal
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/fifo_full_internal
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/fifo_memory
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/fifo_rd_ptr
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/fifo_ren_sync1
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/fifo_ren_sync2
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/fifo_wr_ptr
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/FIFOCLK
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/FIFOEMPTY
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/FIFOFULL
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/FIFOREN
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/FIFORST
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/FIFOWEN
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/FIRCLK
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/FIRENA
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/FIRIFG
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/FIRIN
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/FIR_acc/FIROUT
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/FIRRead
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/FIRRST
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/FIRWrite
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/k
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/M
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/processing_active
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/q
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/W
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/x_delay
add wave -noupdate /a_mcu_tb/U_0/FIR_acc/x_input
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/FIR_acc/y_output
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/AddressBus
add wave -noupdate /a_mcu_tb/U_0/DataBus
add wave -noupdate /a_mcu_tb/U_0/MemReadBus
add wave -noupdate -radix hexadecimal /a_mcu_tb/U_0/CPU/Instruction
add wave -noupdate /a_mcu_tb/U_0/Intr_Controller/CLR_IRQ
add wave -noupdate -expand /a_mcu_tb/U_0/Intr_Controller/FIR_Type
add wave -noupdate -expand /a_mcu_tb/U_0/Intr_Controller/IFG
add wave -noupdate /a_mcu_tb/U_0/Intr_Controller/IntrEn
add wave -noupdate -expand /a_mcu_tb/U_0/Intr_Controller/IntrSrc
add wave -noupdate /a_mcu_tb/U_0/Intr_Controller/INTA
add wave -noupdate -expand /a_mcu_tb/U_0/Intr_Controller/IRQ
add wave -noupdate /a_mcu_tb/U_0/Intr_Controller/INTA_Delayed
add wave -noupdate -radix hexadecimal -childformat {{/a_mcu_tb/U_0/Intr_Controller/TypeReg(7) -radix hexadecimal} {/a_mcu_tb/U_0/Intr_Controller/TypeReg(6) -radix hexadecimal} {/a_mcu_tb/U_0/Intr_Controller/TypeReg(5) -radix hexadecimal} {/a_mcu_tb/U_0/Intr_Controller/TypeReg(4) -radix hexadecimal} {/a_mcu_tb/U_0/Intr_Controller/TypeReg(3) -radix hexadecimal} {/a_mcu_tb/U_0/Intr_Controller/TypeReg(2) -radix hexadecimal} {/a_mcu_tb/U_0/Intr_Controller/TypeReg(1) -radix hexadecimal} {/a_mcu_tb/U_0/Intr_Controller/TypeReg(0) -radix hexadecimal}} -expand -subitemconfig {/a_mcu_tb/U_0/Intr_Controller/TypeReg(7) {-height 15 -radix hexadecimal} /a_mcu_tb/U_0/Intr_Controller/TypeReg(6) {-height 15 -radix hexadecimal} /a_mcu_tb/U_0/Intr_Controller/TypeReg(5) {-height 15 -radix hexadecimal} /a_mcu_tb/U_0/Intr_Controller/TypeReg(4) {-height 15 -radix hexadecimal} /a_mcu_tb/U_0/Intr_Controller/TypeReg(3) {-height 15 -radix hexadecimal} /a_mcu_tb/U_0/Intr_Controller/TypeReg(2) {-height 15 -radix hexadecimal} /a_mcu_tb/U_0/Intr_Controller/TypeReg(1) {-height 15 -radix hexadecimal} /a_mcu_tb/U_0/Intr_Controller/TypeReg(0) {-height 15 -radix hexadecimal}} /a_mcu_tb/U_0/Intr_Controller/TypeReg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {61518139 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 278
configure wave -valuecolwidth 301
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
configure wave -timelineunits ps
update
WaveRestoreZoom {59790548 ps} {61853130 ps}

onerror {resume}
add list -dec -width 26 /a_mcu_tb/U_0/CPU/IFE/PC
add list -dec -width 26 /a_mcu_tb/U_0/CPU/IFE/Next_PC
add list -hex -width 26 /a_mcu_tb/U_0/CPU/IFE/Instruction
add list -hex /a_mcu_tb/U_0/CPU/EXE/Ainput
add list -hex /a_mcu_tb/U_0/CPU/EXE/Binput
add list -hex /a_mcu_tb/U_0/CPU/EXE/ALU_output_mux
add list /a_mcu_tb/U_1/HEX0
add list /a_mcu_tb/U_1/Switches
add list /a_mcu_tb/U_0/IO_interface/SW/GPInput
add list /a_mcu_tb/U_0/IO_interface/SW/MemRead
add list /a_mcu_tb/U_0/IO_interface/SW/GPIO_CS
add list /a_mcu_tb/U_0/OAD/CS_LEDR
add list -hex /a_mcu_tb/U_0/OAD/AddressBus
add list /a_mcu_tb/U_0/OAD/reset
add list /a_mcu_tb/U_0/LEDR
add list -hex /a_mcu_tb/U_0/CPU/MEM/dMemAddr
add list /a_mcu_tb/U_0/CPU/MEM/write_enable
add list /a_mcu_tb/U_0/CPU/MemWrite
add list /a_mcu_tb/U_0/CPU/MemWriteBus
add list /a_mcu_tb/U_0/CPU/MEM/Memwrite
add list /a_mcu_tb/U_0/CPU/MEM/write_enable
add list -hex /a_mcu_tb/U_0/CPU/MEM/address
add list -hex /a_mcu_tb/U_0/CPU/MemAddr
add list /a_mcu_tb/U_0/CPU/INTA_sig
add list -hex /a_mcu_tb/U_0/CPU/DataBus
add list -hex /a_mcu_tb/U_0/CPU/ALU_result
add list /a_mcu_tb/U_0/CPU/MEM/is_ra
add list /a_mcu_tb/U_0/BTCTL
add list /a_mcu_tb/U_0/BTIFG
add list /a_mcu_tb/U_0/Basic_Timer/HEU0
add list -dec /a_mcu_tb/U_0/Basic_Timer/BTCL0
add list -dec /a_mcu_tb/U_0/Basic_Timer/BTCNT
add list /a_mcu_tb/reset
add list -dec /a_mcu_tb/U_0/Basic_Timer/BTCL1
add list /a_mcu_tb/U_0/IRQ_OUT
add list /a_mcu_tb/U_0/Intr_Controller/INTA
add list /a_mcu_tb/U_0/Intr_Controller/INTA_Delayed
add list /a_mcu_tb/KEY1
add list /a_mcu_tb/KEY2
add list /a_mcu_tb/KEY3
add list /a_mcu_tb/U_0/Intr_Controller/IFG
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta collapse
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5

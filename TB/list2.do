onerror {resume}
add list -width 20 /a_mips_tbt/U_0/PC
add list /a_mips_tbt/U_0/INSTCNT_o
add list /a_mips_tbt/U_0/ID_BranchBeq_w
add list /a_mips_tbt/U_0/ID_BranchBne_w
add list /a_mips_tbt/U_0/ID_MemtoReg_w
add list /a_mips_tbt/U_0/ID_RegWrite_w
add list /a_mips_tbt/U_0/ID_MemRead_w
add list /a_mips_tbt/U_0/ID_MemWrite_w
add list /a_mips_tbt/U_0/EX_Sign_extend_w
add list /a_mips_tbt/U_0/EX_ALU_Result_w
add list /a_mips_tbt/U_0/EX_write_data_w
add list /a_mips_tbt/U_0/EX_ALU_Result_w
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta all
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5

--------------- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std.all;
USE work.aux_package.ALL;
USE work.const_package.ALL;
-------------- ENTITY --------------------
ENTITY HazardUnit IS
	PORT( 
		EX_MemtoReg_i, MEM_MemtoReg_i	 		 			: IN STD_LOGIC;
		EX_WriteReg_i, MEM_WriteReg_i, WB_WriteReg_i 			: IN  STD_LOGIC_VECTOR(4 DOWNTO 0);  -- rt and rd mux output
		ID_RegRs_i, ID_RegRt_i 					 			: IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		EX_RegRs_w, EX_RegRt_w					 			: IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		EX_RegWr_i, MEM_RegWr_i, WB_RegWr_i		 			: IN  STD_LOGIC;
		ID_BranchBeq_i, ID_BranchBne_i, ID_Jump_i	 			: IN STD_LOGIC;
		IF_Stall_o, ID_Stall_o, Flush_EX 	 	 			: OUT STD_LOGIC;
		ForwardA_o, ForwardB_o				    			: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		ForwardA_Branch_o, ForwardB_Branch_o				: OUT STD_LOGIC
		);
END 	HazardUnit;
------------ ARCHITECTURE ----------------
ARCHITECTURE structure OF HazardUnit IS
SIGNAL LwStall_w, BranchStall_w : BOOLEAN;
BEGIN
----------- Stall and Flush -----------------------	
	LwStall_w <= EX_MemtoReg_i = '1' AND ( EX_RegRt_w = ID_RegRs_i OR EX_RegRt_w = ID_RegRt_i );
	BranchStall_w <= ((ID_BranchBeq_i = '1' OR ID_BranchBne_i = '1') AND EX_RegWr_i = '1' AND (EX_WriteReg_i = ID_RegRs_i OR EX_WriteReg_i = ID_RegRt_i)) OR (ID_BranchBeq_i = '1' AND MEM_MemtoReg_i = '1' AND (MEM_WriteReg_i = ID_RegRs_i OR MEM_WriteReg_i = ID_RegRt_i));
	
	IF_Stall_o <= '1' WHEN (LwStall_w OR BranchStall_w) ELSE '0';
	ID_Stall_o <= '1' WHEN (LwStall_w OR BranchStall_w) ELSE '0';
	--Flush_EX <= '1' WHEN (LwStall_w OR BranchStall_w OR ID_Jump_i = '1') ELSE '0';
	Flush_EX <= '1' WHEN (LwStall_w OR BranchStall_w) ELSE '0';

----------- Forwarding -----------------------	
    --------------------- Register Forwarding -----------------------
	-- EX Hazard
	ForwardA_o <= "10" WHEN ((MEM_RegWr_i = '1') AND (MEM_WriteReg_i /= "00000") AND (MEM_WriteReg_i = EX_RegRs_w)) ELSE  -- EX Hazard take from MEM
				"01" WHEN (WB_RegWr_i = '1' AND WB_WriteReg_i /= "00000" AND (NOT (MEM_RegWr_i = '1' AND MEM_WriteReg_i /= "00000" AND (MEM_WriteReg_i = EX_RegRs_w))) AND WB_WriteReg_i = EX_RegRs_w)	ELSE -- MEM Hazard take from WB
				"00";

	ForwardB_o <= "10" WHEN (MEM_RegWr_i = '1' AND MEM_WriteReg_i /= "00000" AND MEM_WriteReg_i = EX_RegRt_w) ELSE  -- EX Hazard take from MEM
				"01" WHEN (WB_RegWr_i = '1' AND WB_WriteReg_i /= "00000" AND (NOT (MEM_RegWr_i = '1' AND MEM_WriteReg_i /= "00000" AND (MEM_WriteReg_i = EX_RegRt_w))) AND WB_WriteReg_i = EX_RegRt_w)	ELSE -- MEM Hazard take from WB
				"00";	

	-------------- Branch Forwarding --------------------
	ForwardA_Branch_o <= '1' WHEN ((ID_RegRs_i /= "00000") AND (ID_RegRs_i = MEM_WriteReg_i) AND MEM_RegWr_i = '1') ELSE '0';
	
	ForwardB_Branch_o <= '1' WHEN ((ID_RegRt_i /= "00000") AND (ID_RegRt_i = MEM_WriteReg_i) AND MEM_RegWr_i = '1') ELSE '0';
	



END Structure;
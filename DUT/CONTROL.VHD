------------ Control module (implements MIPS control unit)------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.const_package.all;
------------ Entity -----------------
ENTITY control IS
   PORT( 	
		opcode_i 			: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		funct_i			: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		RegDst_ctrl_o 		: OUT 	STD_LOGIC_VECTOR(1 DOWNTO 0);
		ALUSrc_ctrl_o 		: OUT 	STD_LOGIC;
		MemtoReg_ctrl_o 	: OUT 	STD_LOGIC;
		RegWrite_ctrl_o 	: OUT 	STD_LOGIC;
		MemRead_ctrl_o 	: OUT 	STD_LOGIC;
		MemWrite_ctrl_o 	: OUT 	STD_LOGIC;
		BranchBeq_o 		: OUT 	STD_LOGIC;
		BranchBne_o 		: OUT 	STD_LOGIC;
		Jump_o			: OUT 	STD_LOGIC;
		Jal_o				: OUT 	STD_LOGIC;
		ALUOp_ctrl_o 		: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
		clock, reset	: IN 	STD_LOGIC );
END control;
------------ Architecture -----------------
ARCHITECTURE behavior OF control IS
	SIGNAL  rtype_w, itype_imm_w, lw_w, sw_w, beq_w, Bne_w, Addi_w, Ori_w, Xori_w, Andi_w, Shift_w, Lui_w, Slti_w, JalSignal_w : STD_LOGIC;
	-- Add Relvant Signals Later if needed
BEGIN           
------- Code to generate control signals using opcode bits -------------
	
	-- OPcode Decoder --
	rtype_w 	<=  '1' WHEN opcode_i = "000000" OR opcode_i = "011100" ELSE '0';
	lw_w          <=  '1' WHEN opcode_i = "100011" ELSE '0';
 	sw_w          <=  '1' WHEN opcode_i = "101011" ELSE '0';
   	beq_w         <=  '1' WHEN opcode_i = "000100" ELSE '0';
	Bne_w		<=	'1' WHEN opcode_i = "000101" ELSE '0';
	Addi_w		<=  '1' WHEN opcode_i = "001000" ELSE '0';
	Andi_w 		<=  '1' WHEN opcode_i = "001100" ELSE '0';
	Slti_w		<= 	'1' WHEN opcode_i = "001010" ELSE '0';
	Ori_w		<=  '1' WHEN opcode_i = "001101" ELSE '0';
	Xori_w		<=  '1' WHEN opcode_i = "001110" ELSE '0';
	Lui_w		<=	'1' WHEN opcode_i = "001111" ELSE '0';
	JalSignal_w	<=	'1' WHEN opcode_i = "000011" ELSE '0';
	Jump_o		<=	'1' WHEN opcode_i = "000010" OR opcode_i = "000011" OR (opcode_i = "000000" AND funct_i = "001000") ELSE '0';
	Shift_w		<=  '1' WHEN opcode_i = "000000" AND (funct_i = "000000" OR funct_i = "000010") ELSE '0';

	-- EXEC -- 
	itype_imm_w <= Addi_w OR Andi_w OR Ori_w OR Xori_w OR Lui_w OR Shift_w or Slti_w;
	RegDst_ctrl_o(1)	<= JalSignal_w; -- jal
	RegDst_ctrl_o(0)  	<= rtype_w;
	ALUSrc_ctrl_o   	<= lw_w OR sw_w OR itype_imm_w;
	ALUOp_ctrl_o(1) 	<= rtype_w;
	ALUOp_ctrl_o(0) 	<= beq_w OR Bne_w OR Shift_w; 

		-- MEM -- 
	MemRead_ctrl_o    <= lw_w;
   	MemWrite_ctrl_o   <= sw_w; 
 	BranchBeq_o   <= beq_w;
	BranchBne_o	<= Bne_w;
	Jal_o 		<= JalSignal_w;
	
	-- WB --
	MemtoReg_ctrl_o   <= lw_w;
  	RegWrite_ctrl_o   <= rtype_w OR lw_w OR itype_imm_w OR JalSignal_w;


END behavior;



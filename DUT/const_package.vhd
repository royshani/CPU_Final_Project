---------------------------------------------------------------------------------------------
-- Copyright 2025 Hananya Ribo 
-- Advanced CPU architecture and Hardware Accelerators Lab 361-1-4693 BGU
---------------------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;


package const_package is
---------------------------------------------------------
--	IDECODE constants
---------------------------------------------------------
	constant R_TYPE_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
	constant LW_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100011";
	constant SW_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "101011";
	constant BEQ_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "000100";
	constant BNE_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) :=	"000101";
	constant ANDI_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001100";
	constant ORI_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "001101";
	constant ADDI_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001000";
	constant ADDIU_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001001";	--same as ADDI
	constant LOAD_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001000";	
	constant XORI_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001110";
	constant LUI_OPC :	 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001111";
	constant SLTI_OPC : 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "001010";
	constant MUL_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "011100";
	constant JAL_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "011100";
	constant JMP_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "000010";
	constant JR_OPC : 		STD_LOGIC_VECTOR(5 DOWNTO 0) := "001000";


	

	
--------------------------------------------------------	
-- Rtype FUNC	
--------------------------------------------------------	
	constant ADD_FUN :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100000";
	constant MOV_FUN :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100001";	
	constant SUB_FUN :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100010";
	constant AND_FUN :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100100";
	constant OR_FUN	 :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100101";	
	constant XOR_FUN :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "100110";
	constant SLT_FUN :		STD_LOGIC_VECTOR(5 DOWNTO 0) := "101010";
	constant SLL_FUN :	 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "000000";
	constant SRL_FUN :	 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "000010";
	constant NOP_FUN :	 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "111111";
	constant MUL_FUN :	 	STD_LOGIC_VECTOR(5 DOWNTO 0) := "011000";	
	constant MUL_FUN_ALT :	STD_LOGIC_VECTOR(5 DOWNTO 0) := "000010";	-- Alternative MUL function used in EXECUTE
	

--------------------------------------------------------	
-- ALU Control Constants	
--------------------------------------------------------	
	constant ALU_AND :		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";	-- AND operation
	constant ALU_OR :		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";	-- OR operation
	constant ALU_ADD :		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";	-- ADD operation
	constant ALU_MUL :		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";	-- MUL operation
	constant ALU_XOR :		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";	-- XOR operation
	constant ALU_SLL :		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";	-- Shift Left Logical
	constant ALU_SUB :		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";	-- SUB operation
	constant ALU_SLT :		STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";	-- Set Less Than
	constant ALU_SRL :		STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";	-- Shift Right Logical
	constant ALU_LUI :		STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";	-- Load Upper Immediate
	constant ALU_NOP :		STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";	-- No Operation (default)
	constant ALU_SLTI :		STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";	-- Set Less Than Immediate
	

	constant DATA_BUS_WIDTH	: integer := 32;





end const_package;


----------  Idecode module (implements the register file for the MIPS computer)
LIBRARY IEEE; 			
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.const_package.all;

----------------- ENTITY ----------------
ENTITY Idecode IS
	PORT (
		read_data1_o         : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		read_data2_o         : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		rt_register_o        : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		rd_register_o        : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		write_register_address : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		instruction_i        : IN  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		PC_plus_4_shifted_i  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		RegWrite_ctrl_i      : IN  STD_LOGIC;
		ForwardA_ID          : IN  STD_LOGIC;
		ForwardB_ID          : IN  STD_LOGIC;
		BranchBeq_i          : IN  STD_LOGIC;
		BranchBne_i          : IN  STD_LOGIC;
		Jump_i               : IN  STD_LOGIC;
		JAL_i                : IN  STD_LOGIC; -- NEW Added JAL
		Stall_ID             : IN  STD_LOGIC;
		write_data_i         : IN  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0); -- NEW changed name from write_data to write_data_wb
		Branch_read_data_FW  : IN  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		sign_extend_o        : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		PCSrc_o              : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		JumpAddr_o           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		PCBranch_addr_o      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		clk_i                : IN  STD_LOGIC;
		rst_i                : IN  STD_LOGIC
	);
END Idecode;

------------ ARCHITECTURE ----------------
ARCHITECTURE behavior OF Idecode IS

	TYPE register_file IS ARRAY (0 TO 31) OF STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL RF_q                 : register_file;
	SIGNAL write_reg_addr_w     : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL write_reg_data_w     : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL rs_register_w        : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL rt_register_w        : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL rd_register_w        : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL imm_value_w          : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL read_data_1_w        : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL read_data_2_w        : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL read_data_comp_input_1 : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL read_data_comp_input_2 : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL Opcode_w             : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL sign_extend_w        : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL write_data_mux_out   : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);

BEGIN

	Opcode_w        <= instruction_i(31 DOWNTO 26);
	rs_register_w   <= instruction_i(25 DOWNTO 21);
	rt_register_w   <= instruction_i(20 DOWNTO 16);
	rd_register_w   <= instruction_i(15 DOWNTO 11);
	imm_value_w     <= instruction_i(15 DOWNTO 0);

	-------------- Read Register 1 Operation ---------------------------
	read_data_comp_input_1 <= read_data_1_w WHEN ForwardA_ID = '0' ELSE Branch_read_data_FW;
	read_data_1_w          <= RF_q(CONV_INTEGER(rs_register_w));
	read_data1_o           <= read_data_1_w;

	-------------- Read Register 2 Operation ---------------------------
	read_data_comp_input_2 <= read_data_2_w WHEN ForwardB_ID = '0' ELSE Branch_read_data_FW;
	read_data_2_w          <= RF_q(CONV_INTEGER(rt_register_w));
	read_data2_o           <= read_data_2_w;

	-------------- PCSrc from Read Register Comp -----------------------
	PCSrc_o(1) <= Jump_i;
	PCSrc_o(0) <= BranchBeq_i WHEN ((read_data_comp_input_1 = read_data_comp_input_2) AND Stall_ID = '0') ELSE 
	              BranchBne_i WHEN ((read_data_comp_input_1 /= read_data_comp_input_2) AND Stall_ID = '0') ELSE '0';

	------------- Calc PC Address when branching -----------------------
	PCBranch_addr_o <= PC_plus_4_shifted_i + sign_extend_w(7 DOWNTO 0);
	JumpAddr_o      <= sign_extend_w(7 DOWNTO 0) WHEN Opcode_w(1 DOWNTO 0) = "10" OR Opcode_w(1 DOWNTO 0) = "11"
	                   ELSE read_data_1_w(7 DOWNTO 0);

	-------------- Sign Extend 16-bits to 32-bits ----------------------
	sign_extend_w   <= X"0000" & imm_value_w WHEN imm_value_w(15) = '0' ELSE X"FFFF" & imm_value_w;
	sign_extend_o   <= sign_extend_w;

	------------- JAL Write Data Mux (unused in this version) ----------
	-- write_data_mux_out <= "000000000000000000000000" & PC_plus_4_shifted WHEN Jal = '1' ELSE write_data_wb;

	----------- Register File Process ----------------------------------
	PROCESS
	BEGIN
		WAIT UNTIL clk_i'EVENT AND clk_i = '0';  -- Changed Clock to work on falling edge
		IF rst_i = '1' THEN
			-- Initial register values on reset are register = reg#
			FOR i IN 0 TO 31 LOOP
				RF_q(i) <= CONV_STD_LOGIC_VECTOR(i, DATA_BUS_WIDTH);
			END LOOP;
		ELSIF RegWrite_ctrl_i = '1' AND write_reg_addr_w /= 0 THEN
			RF_q(CONV_INTEGER(write_reg_addr_w)) <= write_reg_data_w;
		END IF;
	END PROCESS;

	rt_register_o     <= rt_register_w;
	rd_register_o     <= rd_register_w;
	write_reg_addr_w  <= write_register_address;
	write_reg_data_w  <= write_data_i;

END behavior;

--------------- Write Back module 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.aux_package.ALL;
USE work.const_package.ALL;
-------------- ENTITY --------------------
ENTITY WRITE_BACK IS
	PORT( 
		alu_result_i, dtcm_data_rd_i	: IN  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		PC_plus_4_shifted_i			: IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		MemtoReg_ctrl_i, Jal_i			: IN  STD_LOGIC;
		write_data_o 					: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		write_data_mux_o				: OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
		);
END 	WRITE_BACK;
------------ ARCHITECTURE ----------------
ARCHITECTURE structure OF WRITE_BACK IS
	SIGNAL write_reg_data_w : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
BEGIN

	write_reg_data_w	<= alu_result_i WHEN MemtoReg_ctrl_i = '0' ELSE dtcm_data_rd_i;
	--write_data 			<= ALU_Result WHEN MemtoReg = '0' ELSE read_data; -- NEW 14:15
	write_data_o 		<= write_reg_data_w;
	write_data_mux_o 	<= write_reg_data_w WHEN Jal_i = '0' ELSE "000000000000000000000000" & PC_plus_4_shifted_i;

END structure;
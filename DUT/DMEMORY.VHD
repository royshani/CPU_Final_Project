----------  Dmemory module (implements the data memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
USE work.const_package.all;
---------------- ENTITY --------------
ENTITY dmemory IS
	GENERIC (MemWidth	: INTEGER;
		WORDS_NUM	: INTEGER;
		ITCM_ADDR_WIDTH	: INTEGER
		);
	PORT(
		dtcm_data_rd_o 			: OUT 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
        dtcm_addr_i 			: IN 	STD_LOGIC_VECTOR( MemWidth-1 DOWNTO 0 );
        dtcm_data_wr_i 			: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
	    	MemRead_ctrl_i, MemWrite_ctrl_i 	: IN 	STD_LOGIC;
        clk_i, rst_i			: IN 	STD_LOGIC );
END dmemory;
------------ ARCHITECTURE -------------
ARCHITECTURE behavior OF dmemory IS
SIGNAL wrclk_w : STD_LOGIC;
BEGIN
	data_memory : altsyncram
	GENERIC MAP  (
		operation_mode => "SINGLE_PORT",
		width_a => DATA_BUS_WIDTH,
		widthad_a => ITCM_ADDR_WIDTH,
		numwords_a => WORDS_NUM,
		lpm_hint => "ENABLE_RUNTIME_MOD = YES,INSTANCE_NAME = DTCM",
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\Users\yanai\Local\Documents\Yanai\University\LABS\CPU Architercture\Lab5\CPU5_new\CODE\DTCM.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		wren_a => MemWrite_ctrl_i,
		clock0 => wrclk_w, -- Falling Edge
		address_a => dtcm_addr_i,
		data_a => dtcm_data_wr_i,
		q_a => dtcm_data_rd_o	);
-- Load memory address register with write clock
-- Data Memory works on falling edge
		wrclk_w <= NOT clk_i;
END behavior;


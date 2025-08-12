library IEEE;
use ieee.std_logic_1164.all;
use work.const_package.all;
use work.cond_comilation_package.all;
package aux_package is
--------------------------------------------------------
	COMPONENT Ifetch IS
	GENERIC (
		MemWidth		: INTEGER;
		SIM				: BOOLEAN;
		PC_WIDTH		: integer := 10;
		NEXT_PC_WIDTH	: integer := 8; -- NEXT_PC_WIDTH = PC_WIDTH-2
		ITCM_ADDR_WIDTH	: integer ;
		WORDS_NUM		: integer ;
		INST_CNT_WIDTH	: integer := 16
	);
	PORT(	instruction_o : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			pc_plus4_o : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			add_result_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			PCSrc_i : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			pc_o : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			addr_res_o : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			clk_i, ena_i, Stall_IF_i, BPADD_ena_i, rst_i : IN STD_LOGIC;
			inst_cnt_o 		: OUT	STD_LOGIC_VECTOR(INST_CNT_WIDTH-1 DOWNTO 0)	
		);
	END COMPONENT;

	COMPONENT Idecode
	PORT(
		read_data1_o : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		read_data2_o : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		rt_register_o : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		rd_register_o : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		write_register_address : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		instruction_i : IN STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		PC_plus_4_shifted_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		RegWrite_ctrl_i : IN STD_LOGIC;
		ForwardA_ID, ForwardB_ID : IN STD_LOGIC;
		BranchBeq_i, BranchBne_i, Jump_i, JAL_i : IN STD_LOGIC;
		Stall_ID : IN STD_LOGIC;
		write_data_i : IN STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		Branch_read_data_FW : IN STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		sign_extend_o : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		PCSrc_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		JumpAddr_o : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		PCBranch_addr_o : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		clk_i, rst_i : IN STD_LOGIC
	);
	END COMPONENT;

	COMPONENT control
	PORT(
		opcode_i : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		funct_i : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		RegDst_ctrl_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		ALUSrc_ctrl_o : OUT STD_LOGIC;
		MemtoReg_ctrl_o : OUT STD_LOGIC;
		RegWrite_ctrl_o : OUT STD_LOGIC;
		MemRead_ctrl_o : OUT STD_LOGIC;
		MemWrite_ctrl_o : OUT STD_LOGIC;
		BranchBeq_o : OUT STD_LOGIC;
		BranchBne_o : OUT STD_LOGIC;
		Jump_o : OUT STD_LOGIC;
		Jal_o : OUT STD_LOGIC;
		ALUOp_ctrl_o : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		clock, reset : IN STD_LOGIC
	);
	END COMPONENT;

	COMPONENT  Execute
	PORT(	read_data1_i 	: IN 	STD_LOGIC_VECTOR( DATA_BUS_WIDTH-1 DOWNTO 0 );
			read_data2_i 	: IN 	STD_LOGIC_VECTOR( DATA_BUS_WIDTH-1 DOWNTO 0 );
			sign_extend_i 	: IN 	STD_LOGIC_VECTOR( DATA_BUS_WIDTH-1 DOWNTO 0 );
			funct_i 			: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			opcode_i			: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALUOp_ctrl_i 	: IN 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			ALUSrc_ctrl_i 	: IN 	STD_LOGIC;
			zero_o 			: OUT	STD_LOGIC;
			RegDst	: IN    STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			alu_res_o 		: OUT	STD_LOGIC_VECTOR( DATA_BUS_WIDTH-1 DOWNTO 0 );
			pc_plus4_i 		: IN 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			Wr_reg_addr     : OUT   STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Wr_reg_addr_0	: IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Wr_reg_addr_1	: IN    STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Wr_data_FW_WB	: IN 	STD_LOGIC_VECTOR( DATA_BUS_WIDTH-1 DOWNTO 0 );
			Wr_data_FW_MEM	: IN 	STD_LOGIC_VECTOR( DATA_BUS_WIDTH-1 DOWNTO 0 );
			ForwardA 		: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);		
			ForwardB		: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);	
			WriteData_EX    : OUT   STD_LOGIC_VECTOR( DATA_BUS_WIDTH-1 DOWNTO 0 )
			);
	END COMPONENT;

	COMPONENT dmemory
	GENERIC (MemWidth	: INTEGER;
		WORDS_NUM	: INTEGER;
		ITCM_ADDR_WIDTH	: INTEGER
		);
	PORT(
		dtcm_data_rd_o : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		dtcm_addr_i : IN STD_LOGIC_VECTOR(MemWidth-1 DOWNTO 0);
		dtcm_data_wr_i : IN STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		MemRead_ctrl_i, MemWrite_ctrl_i : IN STD_LOGIC;
		clk_i, rst_i : IN STD_LOGIC
	);
	END COMPONENT;
	
	COMPONENT WRITE_BACK
	PORT(
		alu_result_i : IN STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		dtcm_data_rd_i : IN STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		PC_plus_4_shifted_i : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		MemtoReg_ctrl_i, Jal_i : IN STD_LOGIC;
		write_data_o : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
		write_data_mux_o : OUT STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
	);
	END COMPONENT;
	
	COMPONENT HazardUnit IS
	PORT( 
		EX_MemtoReg_i, MEM_MemtoReg_i          : IN STD_LOGIC;
		EX_WriteReg_i, MEM_WriteReg_i, WB_WriteReg_i : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		ID_RegRs_i, ID_RegRt_i 					 : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		EX_RegRs_w, EX_RegRt_w					 : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
		EX_RegWr_i, MEM_RegWr_i, WB_RegWr_i		 : IN  STD_LOGIC;
		ID_BranchBeq_i, ID_BranchBne_i, ID_Jump_i	 : IN STD_LOGIC;
		IF_Stall_o, ID_Stall_o, Flush_EX 	 	 : OUT STD_LOGIC;
		ForwardA_o, ForwardB_o				     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		ForwardA_Branch_o, ForwardB_Branch_o		     : OUT STD_LOGIC
		);
	END 	COMPONENT;

	COMPONENT PLL
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
	END COMPONENT;
-----------------------------------------------------------------------------------

end aux_package;




--------------- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
use work.const_package.all;
USE work.aux_package.ALL;
-------------- ENTITY --------------------
ENTITY MIPS IS
	GENERIC ( MemWidth : INTEGER := 10;
			 ITCM_ADDR_WIDTH : INTEGER := 10;
			 WORDS_NUM : INTEGER := 1024;
			 SIM : BOOLEAN := FALSE);
	PORT( rst_i, clk_i, ena					: IN 	STD_LOGIC;
		BPADD								: IN  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		-- Output important signals to pins for easy display in Simulator
		PC									: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		CLKCNT_o							: OUT  STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		STCNT_o								: OUT  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		FHCNT_o								: OUT  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		STRIGGER_o							: OUT  STD_LOGIC;
		INSTCNT_o							: OUT  STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		IFpc_0								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		IFinstruction_o						: OUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
		IDpc_0								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		IDinstruction_o						: OUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
		EXpc_0								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		EXinstruction_o						: OUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
		MEMpc_0								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		MEMinstruction_o					: OUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
		WBpc_0								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		WBinstruction_o						: OUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 )
		);
END 	MIPS;
------------ ARCHITECTURE ----------------
ARCHITECTURE structure OF MIPS IS
	---- FPGA OR ModelSim Signals ----
	SIGNAL dMemAddr_w 											: STD_LOGIC_VECTOR(MemWidth-1 DOWNTO 0);
	SIGNAL rst_Sim_w, ena_Sim_w									: STD_LOGIC;
	SIGNAL MCLK_w 												: STD_LOGIC;

-------------- Signals To support CPI/IPC calculation and break point debug ability --------------------------------

	SIGNAL BPADD_ena_w											: STD_LOGIC;
	SIGNAL run_w												: STD_LOGIC;
	SIGNAL pc_BPADD_w											: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	---------------- Pipeline Registers --------------------------
	-- Forwarding logic
	SIGNAL ForwardA_w, ForwardB_w								: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL ID_ForwardA_w, ID_ForwardB_w							: STD_LOGIC; -- AD LEPO
	
	-- Hazard Logic -- Stall AND Flush
	SIGNAL IFStall_w, IDStall_w, EXFlush_w 						: STD_LOGIC;
	
	--------------------------------------------------------
	
	-------- States Registers ------
	-- Instruction Fetch
	SIGNAL IF_PC_plus_4_w 										: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL IF_IR_w  											: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
	SIGNAL inst_cnt_w 											: STD_LOGIC_VECTOR(15 DOWNTO 0);

	-- Instruction Decode
	SIGNAL ID_PC_plus_4_w 										: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL ID_IR_w 												: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
	SIGNAL ID_read_data_1_w, ID_read_data_2_w 					: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
	SIGNAL ID_Sign_extend_w 									: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
	SIGNAL ID_Wr_reg_addr_0_w, ID_Wr_reg_addr_1_w 				: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL ID_PCBranch_addr_w 									: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ID_JumpAddr_w     									: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ID_PCSrc_w        									: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL ID_ALUOp_w											: STD_LOGIC_VECTOR(1 DOWNTO 0);			
	SIGNAL ID_ALUSrc_w, ID_MemtoReg_w, ID_RegWrite_w, ID_jal_w	: STD_LOGIC;
	SIGNAL ID_Branch_w, ID_MemWrite_w, ID_BranchBeq_w			: STD_LOGIC;
	SIGNAL ID_BranchBne_w, ID_Jump_w,ID_MemRead_w				: STD_LOGIC;
	SIGNAL ID_RegDst_w											: STD_LOGIC_VECTOR(1 DOWNTO 0);
	-- Execute                                            
	SIGNAL EX_ALUOp_w			 								: STD_LOGIC_VECTOR(1 DOWNTO 0);      
	SIGNAL EX_ALUSrc_w, EX_Zero_w, EX_Branch_w, EX_MemWrite_w	: STD_LOGIC;
	SIGNAL EX_MemRead_w, EX_BranchBeq_w,EX_BranchBne_w			: STD_LOGIC;
	SIGNAL EX_Jump_w, EX_jal_w, EX_MemtoReg_w,EX_RegWrite_w		: STD_LOGIC;
	SIGNAL EX_RegDst_w 											: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL EX_PC_plus_4_w				      					: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL EX_IR_w		    			  		 				: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 ); 
	SIGNAL EX_read_data_1_w, EX_read_data_2_w 					: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
	SIGNAL EX_Sign_extend_w				  		 				: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
	SIGNAL EX_Wr_reg_addr_0_w, EX_Wr_reg_addr_1_w				: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL EX_Wr_reg_addr_w 									: STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL EX_write_data_w 										: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL EX_ALU_Result_w 										: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL EX_Opcode_w 											: STD_LOGIC_VECTOR(5 DOWNTO 0);
																
	-- Memory     
	
	SIGNAL MEM_MemWrite_w 										: STD_LOGIC;
	SIGNAL MEM_MemRead_w, MEM_jal_w 							: STD_LOGIC;
	SIGNAL MEM_MemtoReg_w, MEM_RegWrite_w						: STD_LOGIC;
	SIGNAL MEM_PC_plus_4_w 										: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL MEM_ALU_Result_w 									: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL MEM_write_data_w, MEM_read_data_w 					: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
	SIGNAL MEM_Wr_reg_addr_w 									: STD_LOGIC_VECTOR(4 DOWNTO 0);

	
	-- WriteBack
	SIGNAL WB_MemtoReg_w, WB_RegWrite_w, WB_jal_w   			: STD_LOGIC;
	SIGNAL WB_PC_plus_4_w				      						: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL WB_read_data_w											: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
	SIGNAL WB_ALU_Result_w										: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
	SIGNAL WB_Wr_reg_addr_w										: STD_LOGIC_VECTOR( 4 DOWNTO 0 ); 
	SIGNAL WB_write_data_w										: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
	SIGNAL WB_write_data_mux_w									: STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
	------------------------------------------------------

BEGIN
	-------------------------- FPGA or ModelSim -----------------------
	rst_Sim_w 	<= rst_i WHEN SIM ELSE not rst_i;
	ena_Sim_w		<= ena 	 WHEN SIM ELSE not ena;

	G0:
	if (not SIM) generate
	  MCLK: PLL
		PORT MAP (
			inclk0 	=> clk_i,
			c0 		=> MCLK_w
		);
	else generate
		MCLK_w <= clk_i;
	end generate;
   --------------------- PORT MAP COMPONENTS --------------------------
   ----- Instruction Fetch -----
	IFE : Ifetch
	GENERIC MAP(MemWidth => MemWidth, SIM => SIM, WORDS_NUM => WORDS_NUM, ITCM_ADDR_WIDTH => ITCM_ADDR_WIDTH) 
	PORT MAP (	instruction_o => IF_IR_w,
    	    	pc_plus4_o => IF_PC_plus_4_w,
				add_result_i => ID_PCBranch_addr_w( 7 DOWNTO 0 ), 
				PCSrc_i => ID_PCSrc_w,
				pc_o => pc_BPADD_w,      
				addr_res_o => ID_JumpAddr_w,
				clk_i => MCLK_w, 
				ena_i => ena_Sim_w,
				Stall_IF_i => IFStall_w,
				BPADD_ena_i => BPADD_ena_w,
				inst_cnt_o => inst_cnt_w,
				rst_i => rst_Sim_w );
	----- Instruction Decode -----
	ID : Idecode
   	PORT MAP (	read_data1_o => ID_read_data_1_w,
        		read_data2_o => ID_read_data_2_w,
				rt_register_o => ID_Wr_reg_addr_0_w,
				rd_register_o => ID_Wr_reg_addr_1_w,
				write_register_address => WB_Wr_reg_addr_w,
        		instruction_i => ID_IR_w,
				PC_plus_4_shifted_i => ID_PC_plus_4_w(9 DOWNTO 2),
				RegWrite_ctrl_i => WB_RegWrite_w,
				ForwardA_ID => ID_ForwardA_w,
				ForwardB_ID => ID_ForwardB_w,
				BranchBeq_i => ID_BranchBeq_w,
				BranchBne_i => ID_BranchBne_w,
				Jump_i => ID_Jump_w,
				JAL_i => ID_jal_w,
				Stall_ID => IDStall_w,
				write_data_i => WB_write_data_mux_w,
				Branch_read_data_FW => MEM_ALU_Result_w,
				sign_extend_o => ID_Sign_extend_w,
				PCSrc_o => ID_PCSrc_w,
				JumpAddr_o => ID_JumpAddr_w,
				PCBranch_addr_o => ID_PCBranch_addr_w,
        		clk_i => MCLK_w,  
				rst_i => rst_Sim_w );
	
			
	----- Control Unit in Instruction Decode -----
	CTL:   control
	PORT MAP (
		opcode_i => ID_IR_w(31 DOWNTO 26),
		funct_i => ID_IR_w(5 DOWNTO 0),
		RegDst_ctrl_o => ID_RegDst_w,
		ALUSrc_ctrl_o => ID_ALUSrc_w,
		MemtoReg_ctrl_o => ID_MemtoReg_w,
		RegWrite_ctrl_o => ID_RegWrite_w,
		MemRead_ctrl_o => ID_MemRead_w,
		MemWrite_ctrl_o => ID_MemWrite_w,
		BranchBeq_o => ID_BranchBeq_w,
		BranchBne_o => ID_BranchBne_w,
		Jump_o => ID_Jump_w,
		Jal_o => ID_jal_w,
		ALUOp_ctrl_o => ID_ALUOp_w,
		clock => MCLK_w,
		reset => rst_Sim_w
	);
	----- Execute -----
	EXE:  Execute
   	PORT MAP (	Read_data1_i 	=> EX_read_data_1_w,
             	Read_data2_i 	=> EX_read_data_2_w,
				sign_extend_i	=> EX_Sign_extend_w,
                funct_i			=> EX_Sign_extend_w( 5 DOWNTO 0 ),
				opcode_i		=> EX_Opcode_w,
				ALUOp_ctrl_i	=> EX_ALUOp_w,
				ALUSrc_ctrl_i	=> EX_ALUSrc_w,
				zero_o			=> EX_Zero_w,
				RegDst			=> EX_RegDst_w,
                alu_res_o		=> EX_ALU_Result_w,
				pc_plus4_i		=> EX_PC_plus_4_w,
				Wr_reg_addr     => EX_Wr_reg_addr_w,
				Wr_reg_addr_0   => EX_Wr_reg_addr_0_w,
				Wr_reg_addr_1   => EX_Wr_reg_addr_1_w,
				Wr_data_FW_WB	=> WB_write_data_w,  
				Wr_data_FW_MEM	=> MEM_ALU_Result_w, 
				ForwardA		=> ForwardA_w,
				ForwardB		=> ForwardB_w,
				WriteData_EX    => EX_write_data_w
				);
				
	----- Hazard Unit (Stalls AND Flushs AND Forwarding) -----
	Hazard:	HazardUnit
	PORT MAP(	
				EX_MemtoReg_i		=> EX_MemtoReg_w,	
				MEM_MemtoReg_i	=> MEM_MemtoReg_w,
				EX_WriteReg_i		=> EX_Wr_reg_addr_w,
				MEM_WriteReg_i   	=> MEM_Wr_reg_addr_w,
				WB_WriteReg_i		=> WB_Wr_reg_addr_w,
				EX_RegRs_w		=> EX_IR_w(25 DOWNTO 21),
				EX_RegRt_w 		=> EX_IR_w(20 DOWNTO 16),
				ID_RegRs_i		=> ID_IR_w(25 DOWNTO 21),
				ID_RegRt_i 		=> ID_IR_w(20 DOWNTO 16),
				EX_RegWr_i		=> EX_RegWrite_w,
				MEM_RegWr_i   	=> MEM_RegWrite_w,
				WB_RegWr_i		=> WB_RegWrite_w,
				ID_BranchBeq_i	=> ID_BranchBeq_w,
				ID_BranchBne_i	=> ID_BranchBne_w,
				ID_Jump_i			=> ID_Jump_w,
				IF_Stall_o        => IFStall_w,
				ID_Stall_o        => IDStall_w,
				Flush_EX        => EXFlush_w,
				ForwardA_o    	=> ForwardA_w,
				ForwardB_o		=> ForwardB_w,
				ForwardA_Branch_o => ID_ForwardA_w,
				ForwardB_Branch_o	=> ID_ForwardB_w				
	);
		
	----- Data Memory -----
	ModelSim: 
		IF (SIM = TRUE) GENERATE
				dMemAddr_w <= MEM_ALU_Result_w (9 DOWNTO 2);
		END GENERATE ModelSim;
		
	FPGA: 
		IF (SIM = FALSE) GENERATE
				dMemAddr_w <= "00" & MEM_ALU_Result_w (9 DOWNTO 2);
		END GENERATE FPGA;
	
	MEM:  dmemory
	GENERIC MAP(MemWidth => MemWidth,
				WORDS_NUM => WORDS_NUM,
				ITCM_ADDR_WIDTH => ITCM_ADDR_WIDTH) 
	PORT MAP (	dtcm_data_rd_o => MEM_read_data_w,
				dtcm_addr_i => dMemAddr_w,  --jump memory address by 4
				dtcm_data_wr_i => MEM_write_data_w, 
				MemRead_ctrl_i => MEM_MemRead_w, 
				MemWrite_ctrl_i => MEM_MemWrite_w, 
                clk_i => MCLK_w,  
				rst_i => rst_Sim_w );
	----- Write Back -----	
	WB:	WRITE_BACK
	PORT MAP(	
				alu_result_i => WB_ALU_Result_w,
				dtcm_data_rd_i => WB_read_data_w,
				PC_plus_4_shifted_i => WB_PC_plus_4_w(9 DOWNTO 2),
				MemtoReg_ctrl_i => WB_MemtoReg_w,
				Jal_i => WB_jal_w,  
				write_data_o => WB_write_data_w,
				write_data_mux_o => WB_write_data_mux_w
	);
	
	---------------------------------------------------------------------------
	------- PROCESS TO COUNT Clocks, Stalls, Flushs --------
	PC		 	<= pc_BPADD_w;
	BPADD_ena_w 	<= '1' WHEN ( SIM AND BPADD = pc_BPADD_w(9 DOWNTO 2) AND BPADD /= X"00") ELSE '0';
	STRIGGER_o 	<= BPADD_ena_w;
	
	PROCESS (MCLK_w, rst_Sim_w, ena_Sim_w, run_w, BPADD_ena_w, EXFlush_w, IDStall_w, IFStall_w) 
		VARIABLE CLKCNT_sig		: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		VARIABLE STCNT_sig		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		VARIABLE FHCNT_sig		: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	BEGIN
		IF rst_Sim_w = '1' THEN
			CLKCNT_sig  := X"0000";
			STCNT_sig 	:= X"00";
			FHCNT_sig 	:= X"00";
			run_w			<= '0';
		ELSIF (rising_edge(MCLK_w) and run_w = '1' and BPADD_ena_w = '0') THEN 	-- count clk counts on rising edge
			CLKCNT_sig := CLKCNT_sig + 1;
			IF (IDStall_w OR IFStall_w) = '1' THEN 	-- count on rising edge when stall occurs
				STCNT_sig := STCNT_sig + 1;
			END IF;
			IF EXFlush_w = '1' THEN					-- count on rising edge when flush occurs
				FHCNT_sig := FHCNT_sig + 1;
			END IF;
		END IF;
		
		IF BPADD_ena_w = '1' THEN -- if PC got to BreakPointAddr then pause
			run_w			<= '0';
		ELSIF ena_Sim_w = '1' THEN 
			run_w			<= '1';
		END IF;
		------------- Signals To support CPI/IPC calculation -------------
		CLKCNT_o 		<= CLKCNT_sig;
		STCNT_o		<= STCNT_sig;
		FHCNT_o		<= FHCNT_sig;
	END PROCESS;




	----------------------- Connect Pipeline Registers ------------------------
	PROCESS BEGIN
		WAIT UNTIL MCLK_w'EVENT AND MCLK_w = '1';
		IF  (run_w = '1' AND BPADD_ena_w = '0') THEN
			-------------- Instruction Fetch TO Instruction Decode ---------------- 
			IF IDStall_w = '0' THEN 
				ID_PC_plus_4_w <= IF_PC_plus_4_w;
				ID_IR_w <= IF_IR_w;		
			END IF;
			IF (ID_PCSrc_w(0) = '1' OR ID_PCSrc_w(1) = '1')  THEN -- CLR IF_ID
				ID_PC_plus_4_w <= "0000000000";
				ID_IR_w 		 <= X"00000000";			
			END IF;
			-------------------- Instruction Decode TO Execute -------------------- 
			IF EXFlush_w = '1' THEN -- CLR ID_IF register
				----- Control Reg ----
				EX_Branch_w 	     <= '0';
				EX_MemtoReg_w      <= '0';
				EX_RegWrite_w      <= '0';
				EX_MemWrite_w      <= '0';
				EX_MemRead_w	     <= '0';
				EX_RegDst_w 	     <= "00";  
				EX_ALUSrc_w	     <= '0';
				EX_ALUOp_w 	     <= "00";
				EX_Opcode_w		 <= "000000";
				EX_BranchBeq_w	 <= '0';
				EX_BranchBne_w	 <= '0';
				EX_Jump_w			 <= '0';
				EX_jal_w			 <= '0';   
				----- State Reg -----
				EX_PC_plus_4_w     <= "0000000000";
				EX_IR_w			 <= X"00000000";
				EX_read_data_1_w   <= X"00000000";
				EX_read_data_2_w   <= X"00000000";
				EX_Sign_extend_w   <= X"00000000";
				EX_Wr_reg_addr_0_w <= "00000";
				EX_Wr_reg_addr_1_w <= "00000";
			ELSE 
				----- Control Reg -----
				EX_Branch_w 	     <= ID_Branch_w;
				EX_MemtoReg_w      <= ID_MemtoReg_w;
				EX_RegWrite_w      <= ID_RegWrite_w;
				EX_MemWrite_w      <= ID_MemWrite_w;
				EX_MemRead_w	     <= ID_MemRead_w;		
				EX_RegDst_w 	     <= ID_RegDst_w;
				EX_ALUSrc_w	     <= ID_ALUSrc_w;
				EX_ALUOp_w 	     <= ID_ALUOp_w;
				EX_Opcode_w		 <= ID_IR_w(31 DOWNTO 26);
				EX_BranchBeq_w	 <= ID_BranchBeq_w;
				EX_BranchBne_w	 <= ID_BranchBne_w;
				EX_Jump_w			 <= ID_Jump_w;
				EX_jal_w			 <= ID_jal_w;   
				----- State Reg -----
				EX_PC_plus_4_w     <= ID_PC_plus_4_w;	
				EX_IR_w			 <= ID_IR_w;
				EX_read_data_1_w   <= ID_read_data_1_w;  -- rs
				EX_read_data_2_w   <= ID_read_data_2_w;	 -- rt
				EX_Sign_extend_w   <= ID_Sign_extend_w;
				EX_Wr_reg_addr_0_w <= ID_Wr_reg_addr_0_w;
				EX_Wr_reg_addr_1_w <= ID_Wr_reg_addr_1_w;
			END IF;
			
			-------------------------- Execute TO Memory --------------------------- 
			----- Control Reg -----
			MEM_MemtoReg_w    <= EX_MemtoReg_w;
			MEM_RegWrite_w    <= EX_RegWrite_w;
			MEM_MemWrite_w    <= EX_MemWrite_w;
			MEM_MemRead_w	    <= EX_MemRead_w;	
			

			MEM_jal_w			<= EX_jal_w;
			----- State Reg -----
			MEM_PC_plus_4_w	<= EX_PC_plus_4_w;
	
			MEM_ALU_Result_w  <= EX_ALU_Result_w;
			MEM_write_data_w	<= EX_write_data_w;   
			MEM_Wr_reg_addr_w	<= EX_Wr_reg_addr_w;

			
			------------------------- Memory TO WriteBack ------------------------- 
			----- Control Reg -----
			WB_MemtoReg_w		<= MEM_MemtoReg_w;
			WB_RegWrite_w		<= MEM_RegWrite_w;
			WB_jal_w			<= MEM_jal_w;
			
			----- State Reg -----
			WB_PC_plus_4_w	<= MEM_PC_plus_4_w;
			WB_read_data_w	<= MEM_read_data_w;
			WB_ALU_Result_w	<= MEM_ALU_Result_w;
			WB_Wr_reg_addr_w	<= MEM_Wr_reg_addr_w;
		END IF;
		
	END PROCESS;		
	---------------------------------------------------------------------------
	INSTCNT_o <= inst_cnt_w;
	IFpc_0 <= IF_PC_plus_4_w-4;
	IFinstruction_o <= IF_IR_w;
	IDpc_0 <= ID_PC_plus_4_w-4;
	IDinstruction_o <= ID_IR_w;
	EXpc_0 <= EX_PC_plus_4_w-4;
	EXinstruction_o <= EX_IR_w;
	MEMpc_0 <= MEM_PC_plus_4_w-4;
	MEMinstruction_o <= EX_IR_w;
	WBpc_0 <= WB_PC_plus_4_w-4;
	WBinstruction_o <= EX_IR_w;
END structure;
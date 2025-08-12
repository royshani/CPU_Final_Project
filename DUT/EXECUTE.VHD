--------------  Execute module (implements the data ALU and Branch Address Adder for the MIPS computer) ----------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE IEEE.numeric_std.ALL;
USE work.aux_package.ALL;
USE work.const_package.ALL;
------------ Entity -----------------
ENTITY  Execute IS
	generic(
		DATA_BUS_WIDTH : integer := 32;
		FUNCT_WIDTH : integer := 6;
		PC_WIDTH : integer := 10
	);
	PORT(	read_data1_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			read_data2_i 	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			sign_extend_i : IN STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			funct_i : IN STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			opcode_i : IN STD_LOGIC_VECTOR(FUNCT_WIDTH-1 DOWNTO 0);
			ALUOp_ctrl_i 	: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			ALUSrc_ctrl_i : IN STD_LOGIC;
			zero_o 			: OUT	STD_LOGIC;
			RegDst			: IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
			alu_res_o 		: OUT	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			pc_plus4_i : IN STD_LOGIC_VECTOR(PC_WIDTH-1 DOWNTO 0);
			Wr_reg_addr     : OUT   STD_LOGIC_VECTOR(4 DOWNTO 0);
			Wr_reg_addr_0	: IN    STD_LOGIC_VECTOR(4 DOWNTO 0);
			Wr_reg_addr_1	: IN    STD_LOGIC_VECTOR(4 DOWNTO 0);
			Wr_data_FW_WB	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			Wr_data_FW_MEM	: IN 	STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
			ForwardA 		: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);		
			ForwardB		: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
			WriteData_EX    : OUT   STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0)
			);
END Execute;
------------ Architecture -----------------
ARCHITECTURE behavior OF Execute IS
SIGNAL a_input_w, b_input_w : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL Aforward_mux, Bforward_mux : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
SIGNAL alu_out_mux_w : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0);
--SIGNAL Branch_Add 				  : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL alu_ctl_w : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL write_register_address : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL write_register_address_1 : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL write_register_address_0 : STD_LOGIC_VECTOR(4 DOWNTO 0);
BEGIN
--------------- ALU Inputs: A,B ----------------				
	------------ Forwarding ----------------
		-- Forward A
	WITH ForwardA SELECT 
			Aforward_mux <= read_data1_i    WHEN "00",
							Wr_data_FW_WB  WHEN "01",
							Wr_data_FW_MEM WHEN "10",
							X"00000000"	   WHEN OTHERS;
		-- Forward B
	WITH ForwardB SELECT 
			Bforward_mux <= read_data2_i    WHEN "00",
							Wr_data_FW_WB  WHEN "01",
							Wr_data_FW_MEM WHEN "10",
							X"00000000"	   WHEN OTHERS;
							
	-- ALU A input mux after forwarding (mux for adding shift)
	a_input_w <= 	Bforward_mux WHEN (ALUOp_ctrl_i = "11") ELSE  -- When Performing Shift, A should get data from reg2
				Aforward_mux;
	-- ALU B input mux after forwarding
	b_input_w <= 	Bforward_mux WHEN ( ALUSrc_ctrl_i = '0' ) ELSE
				sign_extend_i(DATA_BUS_WIDTH-1 DOWNTO 0);		
	WriteData_EX <= Bforward_mux;

-------------- Generate ALU control bits (Integrated ALU_CONTROL) -------------
ALU_CONTROL_PROCESS: PROCESS (ALUOp_ctrl_i, funct_i, opcode_i)
BEGIN
	CASE ALUOp_ctrl_i IS
		WHEN "10" => -- r-type
			CASE funct_i IS
				WHEN ADD_FUN => alu_ctl_w <= ALU_ADD; -- add
				WHEN MOV_FUN => alu_ctl_w <= ALU_ADD; -- mov
				WHEN SUB_FUN => alu_ctl_w <= ALU_SUB; -- sub
				WHEN MUL_FUN_ALT => alu_ctl_w <= ALU_MUL; -- mul (using alternative function code)
				WHEN AND_FUN => alu_ctl_w <= ALU_AND; -- and
				WHEN OR_FUN => alu_ctl_w <= ALU_OR; -- or
				WHEN XOR_FUN => alu_ctl_w <= ALU_XOR; -- xor
				WHEN SLT_FUN => alu_ctl_w <= ALU_SLT; -- slt
				WHEN OTHERS   => alu_ctl_w <= ALU_NOP; -- else
			END CASE;				
		WHEN "00" => -- i-type
			CASE opcode_i IS
				WHEN LW_OPC => alu_ctl_w <= ALU_ADD; -- lw
				WHEN SW_OPC => alu_ctl_w <= ALU_ADD; -- sw
				WHEN ADDI_OPC => alu_ctl_w <= ALU_ADD; -- addi
				WHEN ANDI_OPC => alu_ctl_w <= ALU_AND; -- andi
				WHEN ORI_OPC => alu_ctl_w <= ALU_OR; -- ori
				WHEN XORI_OPC => alu_ctl_w <= ALU_XOR; -- xori
				WHEN LUI_OPC => alu_ctl_w <= ALU_LUI; -- lui
				WHEN SLTI_OPC => alu_ctl_w <= ALU_SLTI; -- slti
		        WHEN OTHERS   => alu_ctl_w <= ALU_NOP; -- else
			END CASE;			
		WHEN "01" 	=> -- beq, bne
								 alu_ctl_w <= ALU_SUB; 		
 	 	WHEN "11"	=>  -- shift
			CASE funct_i IS
				WHEN SLL_FUN => alu_ctl_w <= ALU_SLL; -- sll
				WHEN SRL_FUN => alu_ctl_w <= ALU_SRL; -- srl
				WHEN OTHERS   => alu_ctl_w <= ALU_NOP; -- else
			END CASE;
		
		WHEN OTHERS =>  
								 alu_ctl_w <= ALU_NOP; -- else	
  	END CASE;
END PROCESS;

----------------- Mux for Register Write Address ---------------------
	 Wr_reg_addr <= "11111"			WHEN RegDst = "10" ELSE -- jal
					Wr_reg_addr_1 	WHEN RegDst = "01" ELSE -- !!maybe switch to i decode
					Wr_reg_addr_0;
------------ Generate Zero Flag ----------------------------
	zero_o <= '1' WHEN ( alu_out_mux_w(DATA_BUS_WIDTH-1 DOWNTO 0) = X"00000000"  ) ELSE	
			'0';    
-- ------------- Select ALU output  ----------------------------      
 	alu_res_o <= alu_out_mux_w(DATA_BUS_WIDTH-1 DOWNTO 0);
		
------------ Adder to compute Branch Address ----------------
--	Branch_Add	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend( 7 DOWNTO 0 ) ;
--	Add_result 	<= Branch_Add( 7 DOWNTO 0 );

------------ ALU Process (Integrated ALU) -----------------------------
ALU_PROCESS: PROCESS ( alu_ctl_w, a_input_w, b_input_w )
    variable product : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 downto 0);
    variable tmp : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 downto 0);
BEGIN
    --------------- Select ALU operation ---------------------
    CASE alu_ctl_w IS
        -- ALU performs ALUresult = A_input AND B_input
        WHEN ALU_AND    =>    alu_out_mux_w    <= a_input_w AND b_input_w; 
        -- ALU performs ALUresult = A_input OR B_input
        WHEN ALU_OR     =>    alu_out_mux_w    <= a_input_w OR b_input_w;
        -- ALU performs ALUresult = A_input + B_input
        WHEN ALU_ADD    =>    alu_out_mux_w    <= a_input_w + b_input_w; 
        -- ALU performs ALUresult = A_input * B_input
        WHEN ALU_MUL    =>    product := a_input_w(15 DOWNTO 0) * b_input_w(15 DOWNTO 0); -- result 64 bit
                            alu_out_mux_w <= product; -- Take Lower Part
        -- ALU performs ALUresult = A_input XOR B_input
        WHEN ALU_XOR    =>    alu_out_mux_w    <= a_input_w XOR b_input_w;
        -- ALU performs ALUresult = A_input SLL B_input
        WHEN ALU_SLL    =>    alu_out_mux_w    <=    std_logic_vector(shift_left(ieee.numeric_std.unsigned(a_input_w),to_integer(ieee.numeric_std.unsigned(b_input_w(10 downto 6)))));
        -- ALU performs ALUresult = A_input SRL B_input
        WHEN ALU_SRL    =>    alu_out_mux_w    <=    std_logic_vector(shift_right(ieee.numeric_std.unsigned(a_input_w),to_integer(ieee.numeric_std.unsigned(b_input_w(10 downto 6))))); 
        -- ALU performs ALUresult = A_input -B_input
        WHEN ALU_SUB    =>    alu_out_mux_w    <= a_input_w - b_input_w; 
        -- ALU performs SLT
        WHEN ALU_SLT  => 
            tmp := (others => '0');
            if ieee.numeric_std.signed(a_input_w) < ieee.numeric_std.signed(b_input_w) then
                tmp(0) := '1';
            end if;
            alu_out_mux_w <= tmp;
        -- ALU performs SLTi
        WHEN ALU_SLTI => 
            tmp := (others => '0');
            if ieee.numeric_std.signed(a_input_w) < ieee.numeric_std.signed(b_input_w) then
                tmp(0) := '1';
            end if;
            alu_out_mux_w <= tmp;
        -- ALU performs LUI
        WHEN ALU_LUI => alu_out_mux_w <= b_input_w(15 downto 0) & X"0000";
        -- OUTPUT ZERO
        WHEN OTHERS    =>    alu_out_mux_w    <= X"00000000" ;
    END CASE;
END PROCESS;

  
END behavior;


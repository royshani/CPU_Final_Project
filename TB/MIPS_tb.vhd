ENTITY a_MIPS_tbt IS
-- Declarations

END a_mips_tbt ;


--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.aux_package.ALL;
use work.const_package.all;
use work.cond_comilation_package.all;
LIBRARY work;

ARCHITECTURE struct OF a_mips_tbt IS

   -- Architecture declarations

   -- Internal signal declarations
   SIGNAL ALU_res_o  : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
   SIGNAL Branch_o      : STD_LOGIC;
   SIGNAL Instruction_o : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
   SIGNAL pc_o    : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
   SIGNAL Regwrite_o    : STD_LOGIC;
   SIGNAL Zero_tb        : STD_LOGIC;
   SIGNAL clk_tb           : STD_LOGIC;
   SIGNAL read_data_1_tb : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
   SIGNAL read_data_2_tb : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
   SIGNAL rst_tb           : STD_LOGIC;
   SIGNAL write_data_tb  : STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
   SIGNAL CLKCNT_tb          : STD_LOGIC_VECTOR(15 DOWNTO 0);
   SIGNAL STCNT_tb           : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL FHCNT_tb           : STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL BPADD_tb           : STD_LOGIC_VECTOR(7 DOWNTO 0):= "00011001";
   SIGNAL STtrigger_tb       : STD_LOGIC;
   SIGNAL ena_tb             : STD_LOGIC;
   


   -- Component Declarations
   COMPONENT MIPS
	GENERIC ( MemWidth : INTEGER := 10;
			 ITCM_ADDR_WIDTH : INTEGER := 10;
			 WORDS_NUM : INTEGER := 1024;
			 SIM : BOOLEAN := TRUE);
	PORT( rst_i, clk_i, ena		: IN  STD_LOGIC; 
      BPADD						: IN  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		-- Output important signals to pins for easy display in Simulator
		PC							: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		CLKCNT_o					: OUT  STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		STCNT_o						: OUT  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		FHCNT_o						: OUT  STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		STRIGGER_o					: OUT  STD_LOGIC;
		INSTCNT_o					: OUT  STD_LOGIC_VECTOR( 15 DOWNTO 0 );
		IFpc_0						: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		IFinstruction_o				: OUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
		IDpc_0						: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		IDinstruction_o				: OUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
		EXpc_0						: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		EXinstruction_o				: OUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
		MEMpc_0						: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		MEMinstruction_o				: OUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 );
		WBpc_0						: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		WBinstruction_o				: OUT  STD_LOGIC_VECTOR(DATA_BUS_WIDTH-1 DOWNTO 0 )
		);
	END 	COMPONENT;
   COMPONENT MIPS_test_tb
   PORT (
      ALU_res_o  : IN     STD_LOGIC_VECTOR ( DATA_BUS_WIDTH-1 DOWNTO 0 );
      Branch_o      : IN     STD_LOGIC ;
      Instruction_o : IN     STD_LOGIC_VECTOR ( DATA_BUS_WIDTH-1 DOWNTO 0 );
      pc_o    : IN     STD_LOGIC_VECTOR ( 9 DOWNTO 0 );
      Regwrite_o    : IN     STD_LOGIC ;
      Zero_tb        : IN     STD_LOGIC ;
      read_data_1_tb : IN     STD_LOGIC_VECTOR ( DATA_BUS_WIDTH-1 DOWNTO 0 );
      read_data_2_tb : IN     STD_LOGIC_VECTOR ( DATA_BUS_WIDTH-1 DOWNTO 0 );
      write_data_tb  : IN     STD_LOGIC_VECTOR ( DATA_BUS_WIDTH-1 DOWNTO 0 );
      clk_tb           : OUT    STD_LOGIC ;
      ena_tb             : OUT    STD_LOGIC;
      rst_tb           : OUT    STD_LOGIC 
   );
   END COMPONENT;

BEGIN


   -- Instance port mappings.
   U_0 : MIPS
	  GENERIC MAP (
		 MemWidth => 8,
       ITCM_ADDR_WIDTH => 8,
       WORDS_NUM => 256,
		 SIM => TRUE ) 
      PORT MAP (
         rst_i           => rst_tb,
         clk_i           => clk_tb,
         ena             => ena_tb,
         PC              => pc_o,
         CLKCNT_o   		    => CLKCNT_tb,
         STCNT_o 			 => STCNT_tb,
         FHCNT_o 			 => FHCNT_tb,
         BPADD 			 => BPADD_tb,
		 STRIGGER_o        => STtrigger_tb
      );
   U_1 : MIPS_test_tb
      PORT MAP (
         ALU_res_o  => ALU_res_o,
         Branch_o      => Branch_o,
         Instruction_o => Instruction_o,
         pc_o    => pc_o,
         Regwrite_o    => Regwrite_o,
         Zero_tb        => Zero_tb,
         read_data_1_tb => read_data_1_tb,
         read_data_2_tb => read_data_2_tb,
         write_data_tb  => write_data_tb,
         clk_tb           => clk_tb,
         ena_tb             => ena_tb,
         rst_tb           => rst_tb
      );

END struct;

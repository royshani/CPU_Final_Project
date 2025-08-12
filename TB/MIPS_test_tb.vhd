--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.const_package.all;

ENTITY MIPS_test_tb IS
   PORT( 
      ALU_res_o  : IN     STD_LOGIC_VECTOR ( DATA_BUS_WIDTH-1 DOWNTO 0 );
      Branch_o      : IN     STD_LOGIC;
      Instruction_o : IN     STD_LOGIC_VECTOR ( DATA_BUS_WIDTH-1 DOWNTO 0 );
      pc_o    : IN     STD_LOGIC_VECTOR ( 9 DOWNTO 0 );
      Regwrite_o    : IN     STD_LOGIC;
      Zero_tb        : IN     STD_LOGIC;
      read_data_1_tb : IN     STD_LOGIC_VECTOR ( DATA_BUS_WIDTH-1 DOWNTO 0 );
      read_data_2_tb : IN     STD_LOGIC_VECTOR ( DATA_BUS_WIDTH-1 DOWNTO 0 );
      write_data_tb  : IN     STD_LOGIC_VECTOR ( DATA_BUS_WIDTH-1 DOWNTO 0 );
      clk_tb           : OUT    STD_LOGIC;
      ena_tb             : OUT    STD_LOGIC;
      rst_tb           : OUT    STD_LOGIC
   );

-- Declarations

END MIPS_test_tb ;


--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;


ARCHITECTURE struct OF MIPS_test_tb IS

   -- ModuleWare signal declarations(v1.9) for instance 'U_0' of 'clk'
   SIGNAL mw_U_0clk : std_logic;
   SIGNAL mw_U_0disable_clk : boolean := FALSE;

   -- ModuleWare signal declarations(v1.9) for instance 'U_1' of 'pulse'
   SIGNAL mw_U_1pulse : std_logic :='0';


BEGIN

   -- ModuleWare code(v1.9) for instance 'U_0' of 'clk'
   u_0clk_proc: PROCESS
   BEGIN
      WHILE NOT mw_U_0disable_clk LOOP
         mw_U_0clk <= '0', '1' AFTER 50 ns;
         WAIT FOR 100 ns;
      END LOOP;
      WAIT;
   END PROCESS u_0clk_proc;
   mw_U_0disable_clk <= TRUE AFTER 10000000 ns;
   clk_tb <= mw_U_0clk;

   -- ModuleWare code(v1.9) for instance 'U_1' of 'pulse'
   ena_tb	 <= '1';
   rst_tb <= mw_U_1pulse;
   u_1pulse_proc: PROCESS
   BEGIN
      mw_U_1pulse <= 
         '0',
         '1' AFTER 20 ns,
         '0' AFTER 120 ns;
      WAIT;
    END PROCESS u_1pulse_proc;

   -- Instance port mappings.

END struct;

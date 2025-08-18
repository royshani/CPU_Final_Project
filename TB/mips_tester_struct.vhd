
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MCU_tester IS
	GENERIC(IOSize : INTEGER := 8);
	PORT( 
		HEX0, HEX1			: IN	STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX2, HEX3			: IN	STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX4, HEX5			: IN	STD_LOGIC_VECTOR(6 DOWNTO 0);
		Switches			: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
		clock       		: OUT   STD_LOGIC;
		ena					: OUT   STD_LOGIC;
		KEY1, KEY2, KEY3	: OUT	STD_LOGIC;
		reset       : OUT   STD_LOGIC
   );



END MCU_tester;


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;


ARCHITECTURE struct OF MCU_tester IS


   SIGNAL mw_U_0clk : std_logic;
   SIGNAL mw_U_0disable_clk : boolean := FALSE;
   SIGNAL mw_U_1pulse : std_logic :='0';


BEGIN

 
   u_0clk_proc: PROCESS
   BEGIN
      WHILE NOT mw_U_0disable_clk LOOP
         mw_U_0clk <= '0', '1' AFTER 50 ns;
         WAIT FOR 100 ns;
      END LOOP;
      WAIT;
   END PROCESS u_0clk_proc;
   mw_U_0disable_clk <= TRUE AFTER 10000000 ns;
   clock <= mw_U_0clk;


   ena	 <= '1';
   reset <= mw_U_1pulse;
   --reset <= '0';
   u_1pulse_proc: PROCESS
   BEGIN
      mw_U_1pulse <= 
         '0',
         '1' AFTER 50 ns,
         '0' AFTER 10000 ns;
      WAIT;
    END PROCESS u_1pulse_proc;


   -- Toggle Switches between 0x00 and 0x01 every 20000 ns
   switch_toggle_proc: PROCESS
   BEGIN
      Switches <= X"00";
      WAIT FOR 10000 ns;
      WHILE TRUE LOOP
         Switches <= X"69";
         WAIT FOR 20000 ns;
         Switches <= X"42";
         WAIT FOR 20000 ns;
      END LOOP;
   END PROCESS switch_toggle_proc;

 
  inter_key1_proc: PROCESS
  BEGIN
        KEY1 <= '1';
        WAIT FOR 10000 ns;
        WHILE TRUE LOOP
           KEY1 <= '1';
           WAIT FOR 200 ns;
           KEY1 <= '1';
           WAIT FOR 200000 ns;
        END LOOP;
  END PROCESS inter_key1_proc;
   
  inter_key2_proc: PROCESS
  BEGIN
        KEY2 <= '1';
        WAIT FOR 10000 ns; -- phase offset
        WHILE TRUE LOOP
           KEY2 <= '0';
           WAIT FOR 200 ns;
           KEY2 <= '1';
           WAIT FOR 40000000 ns;
        END LOOP;
  END PROCESS inter_key2_proc;
  
  inter_key3_proc: PROCESS
  BEGIN
        KEY3 <= '1';
        WAIT FOR 70000 ns; -- phase offset
        WHILE TRUE LOOP
           KEY3 <= '1';
           WAIT FOR 200 ns;
           KEY3 <= '1';
           WAIT FOR 200000 ns;
        END LOOP;
  END PROCESS inter_key3_proc;
   
 
END struct;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.aux_package.ALL;
-----------------------------------------
-- Entity Declaration for BTIMER
-----------------------------------------
ENTITY BTIMER IS
	GENERIC(DataBusSize	: integer := 32);
	PORT( 
		Addr	: IN	STD_LOGIC_VECTOR(11 DOWNTO 0);
		BTRead	: IN	STD_LOGIC;
		BTWrite	: IN	STD_LOGIC;
		MCLK	: IN 	STD_LOGIC;
		reset	: IN 	STD_LOGIC;
		BTCTL	: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		BTCCR0	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		BTCCR1	: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		BTCNT_io: INOUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
		IRQ_OUT : IN	STD_LOGIC;
		BTIFG	: OUT 	STD_LOGIC;
		BTOUT	: OUT	STD_LOGIC
		);
END BTIMER;
----------------------------------------
-- Architecture Definition
----------------------------------------
ARCHITECTURE structure OF BTIMER IS
	SIGNAL CLK		: STD_LOGIC;
	SIGNAL DIV		: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL BTCNT	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SIGNAL BTCL0	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL BTCL1	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL HEU0		: STD_LOGIC := '0';
	SIGNAL BTCNT_eq_BTCL0 : STD_LOGIC := '0';
	SIGNAL BTCNT_eq_BTCL0_prev : STD_LOGIC := '0';
	SIGNAL PWM		: STD_LOGIC;
	-- Prescaler select (2 bits) and clear strobe (1 bit)
	--signal BTIP  : std_logic_vector(1 downto 0);
	
	-- Updated aliases for new BTCTL bit mapping
	ALIAS BTIPx		IS BTCTL(1 DOWNTO 0); -- 2-bit prescaler select
	ALIAS BTCLR		IS BTCTL(2);          -- Basic Timer Clear strobe
	ALIAS BTSSEL	IS BTCTL(4 DOWNTO 3);
	ALIAS BTHOLD	IS BTCTL(5);
	ALIAS BTOUTEN	IS BTCTL(6);
	
BEGIN

	PROCESS (MCLK) BEGIN
		IF (falling_edge(MCLK)) and BTCNT = X"00000000" THEN -- added modification to counter compare values only when counter is 0
				BTCL0 <= BTCCR0;
				BTCL1 <= BTCCR1;
		END IF;
	END PROCESS;
	
	-- Determines the clock division based on BTCTL
	WITH BTSSEL SELECT DIV	<=
		"0001"	WHEN "00", -- 1
		"0010"	WHEN "01", -- 2
		"0100"	WHEN "10", -- 4
		"1000"	WHEN "11", -- 8
		"0001"	WHEN OTHERS;
		
	-- Generates PWM signal based on timer counts
	
	PROCESS (CLK, Addr) BEGIN
	
		IF reset = '1' THEN
			PWM <= '1';
		ELSIF (falling_edge(CLK)) THEN
			IF (BTOUTEN = '0') THEN
				PWM	<= '1';
			ELSIF (BTCNT = BTCL0 OR BTCNT = BTCL1) THEN
				PWM	<= NOT PWM; -- Toggle PWM signal

			END IF;
		END IF;
	END PROCESS;
	BTOUT	<= PWM;

		
	PROCESS(MCLK, CLK, reset, Addr)
	BEGIN
		IF (reset = '1' OR IRQ_OUT = '1') THEN
			BTCNT <= (others => '0');
			HEU0  <= '0';
			BTCNT_eq_BTCL0_prev <= '0';
	
		ELSIF (falling_edge(CLK)) THEN
			-- Save previous comparator result
			BTCNT_eq_BTCL0_prev <= BTCNT_eq_BTCL0;
			HEU0 <= '0';  -- default clear
	
			-- BTCLR: force clear
			IF (BTCLR = '1') THEN
				BTCNT <= (others => '0');
	
			ELSIF (Addr = X"820" AND BTWrite = '1') THEN
				BTCNT <= BTCNT_io;
	
			ELSIF (BTHOLD = '0') THEN
				BTCNT <= BTCNT + 1;
				IF (BTCNT = BTCL0) THEN
					HEU0 <= '1';                -- single-cycle pulse
					BTCNT <= (others => '0');   -- reset counter
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	
	
	-- Calculates the divided clock for BTCNT based on MCLK
	PROCESS(MCLK, reset, CLK)
		VARIABLE BT_COUNTER	: STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
	BEGIN
		IF reset = '1' THEN
			CLK 	<= '0';
			BT_COUNTER := "0000";
		ELSIF(falling_edge(MCLK)) THEN
			IF(DIV = X"1") THEN -- Reset counter if division is 1
				BT_COUNTER := "0000";
				CLK <= NOT CLK;
			ELSE
			BT_COUNTER := BT_COUNTER + 1;
				IF (BT_COUNTER = DIV) THEN
					BT_COUNTER := "0000";
					CLK <= NOT CLK;	
				END IF;
			END IF;
		END IF;
	END PROCESS;
		
	
	-- Handles data transfer to/from BTCNT_io based on address and read signal
	BTCNT_io <= BTCNT WHEN (Addr = X"820" AND BTRead = '1') ELSE (OTHERS => 'Z');	
	
-- One-shot pulse generation for HEU0 inside the process
-- BTCNT_eq_BTCL0 is a simple comparator
BTCNT_eq_BTCL0 <= '1' WHEN (BTCNT = BTCL0) ELSE '0';

-- Determine interrupt flag based on BTCNT
WITH BTIPx SELECT BTIFG <= 
    BTCNT(31)  WHEN "11",  -- divide by 1
    BTCNT(27)  WHEN "10",  -- divide by 4
    BTCNT(23)  WHEN "01",  -- divide by 8
    HEU0       WHEN "00",  -- when BTCNT = BTCL0
    '0'        WHEN OTHERS;

	
END structure;
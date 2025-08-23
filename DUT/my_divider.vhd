library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE work.aux_package.ALL;
-----------------------------------------
-- Entity Declaration for Divider
-----------------------------------------
entity Divider is
    Port (
--------------------------------------------------
    -- fir interface ALREADY USED
        FIRCLK     : in STD_LOGIC;          -- Clock signal
        FIFOCLK     : in STD_LOGIC;          -- Clock signal
		Addr	: IN	STD_LOGIC_VECTOR(11 DOWNTO 0);
        reset   : in STD_LOGIC;        -- Asynchronous reset signal
        ena     : in STD_LOGIC;        -- Start signal to begin the division
        FIRIFG  : buffer STD_LOGIC := '0';         -- Indicates an overflow condition (changed from divifg)
        FIRIFG_type : out STD_LOGIC_VECTOR(1 DOWNTO 0); -- added for fir!
        DataBus		: INOUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- FIR control register is now inout
        FIRCTL     : buffer STD_LOGIC_VECTOR(7 downto 0);

        -- Data interface
        FIRIN    : in  STD_LOGIC_VECTOR(31 downto 0);   -- FIR input data
        FIROUT   : out STD_LOGIC_VECTOR(31 downto 0) := (others => '1');   -- FIR output data


        -- Coefficient interface
        COEF0,COEF1,COEF2,COEF3,
        COEF4,COEF5,COEF6,COEF7 : in STD_LOGIC_VECTOR(7 downto 0);  -- added for fir!
--------------------------------------------------

--------------------------------------------------
    -- Divider interface NEED TO CHANGE FOR FIR!
        dividend : in  STD_LOGIC_VECTOR (31 downto 0); -- Input for dividend (32-bit)
        divisor : in  STD_LOGIC_VECTOR (31 downto 0); -- Input for divisor (32-bit)
        quotient_OUT : out  STD_LOGIC_VECTOR (31 downto 0); -- Output for quotient (32-bit)
        remainder_OUT : out  STD_LOGIC_VECTOR (31 downto 0); -- Output for remainder (32-bit)
        FIRCTLread	: IN	STD_LOGIC;
        FIRCTLwrite	: IN	STD_LOGIC
--------------------------------------------------
    );
end Divider;
----------------------------------------
-- Architecture Definition
----------------------------------------
architecture Behavioral of Divider is

    -- Define the states for the Finite State Machine (FSM)
    type state_type is (idle, STATE_FIFO, STATE_FIR);

    -- Constants for FIR
    constant M : integer := 8;  -- Number of filter taps
    constant W : integer := 24; -- Data width
    constant k : integer := 8;  -- FIFO depth parameter
    type coeff_array is array (0 to M-1) of STD_LOGIC_VECTOR(31 downto 0);
    type fifo_array is array (0 to k-1) of STD_LOGIC_VECTOR(W-1 downto 0);
    type delay_line is array (0 to M-1) of STD_LOGIC_VECTOR(W-1 downto 0);
    -- FIR signals
--------------------------------------------------
    -- SIGNAL FIFOWEN  : STD_LOGIC := '0'; -- added for fir!
    -- SIGNAL FIFORST  : STD_LOGIC := '0'; -- added for fir!
    -- SIGNAL FIFOFULL  : STD_LOGIC := '0'; -- added for fir!
    -- SIGNAL FIFOEMPTY  : STD_LOGIC := '0'; -- added for fir!
    -- SIGNAL FIRRST  : STD_LOGIC := '0'; -- added for fir!
    -- SIGNAL FIRENA  : STD_LOGIC := '0'; -- added for fir!
    SIGNAL FIFOREN  : STD_LOGIC := '0'; -- added for fir!
    signal fifowen_internal : STD_LOGIC := '0'; -- added for fir!
    signal FIRCTL_internal : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- added for fir!
    signal coefficients   : coeff_array := (others => (others => '0'));
    SIGNAL y_counter : unsigned(5 DOWNTO 0) := (others => '0'); -- added for fir!
    signal firout_ready : STD_LOGIC := '0'; -- added for fir!
    -- Processing signals
    signal x_input        : STD_LOGIC_VECTOR(W-1 downto 0) := (others => '0');
    signal y_output       : STD_LOGIC_VECTOR(31 downto 0)  := (others => '0');
    signal processing_active : STD_LOGIC := '0';
    signal x_delay : delay_line := (others => (others => '0'));
--------------------------------------------------
    -- FIFO signals
    signal fifo_memory    : fifo_array := (others => (others => '0'));
    signal fifo_wr_ptr    : integer range 0 to k-1 := 0;
    signal fifo_rd_ptr    : integer range 0 to k-1 := 0;
    signal fifo_count_wr  : integer range 0 to k := 0;
    signal fifo_count_rd  : integer range 0 to k := 0;
    signal fifo_count     : integer range 0 to k := 0;
--------------------------------------------------
    -- Synchronizer signals for FIR -> FIFO pulse
    signal fir_pulse   : std_logic := '0';
    signal sync_ff1    : std_logic := '0';
    signal sync_ff2    : std_logic := '0';
    signal sync_ff3    : std_logic := '0';  -- For FIFO->FIR handshake
    signal sync_ff4    : std_logic := '0';  -- For FIFO->FIR handshake

--------------------------------------------------
    -- Alias for FIRCTL_internal bits
    alias FIRENA is FIRCTL_internal(0);
    alias FIRRST is FIRCTL_internal(1);
    alias FIFOFULL is FIRCTL_internal(2);
    alias FIFOEMPTY is FIRCTL_internal(3);
    alias FIFORST is FIRCTL_internal(4);
    alias FIFOWEN is FIRCTL_internal(5);
    
    
    
    
    
    -- Signals for FSM state registers and next state values
    signal state_reg, state_next : state_type;   
    -- Registers for intermediate values during the division
    signal z_reg, z_next : unsigned(64 downto 0);  -- z_reg needs to store 64 bits: 32 for remainder + 32 for quotient
    signal divisor_reg, divisor_next : unsigned(31 downto 0);  -- divisor_reg is 32 bits for the divisor
    signal i_reg, i_next : unsigned(5 downto 0);   -- Counter to count 32 iterations
	signal quotient : STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- Output for quotient (32-bit)
    signal remainder:  STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- Output for remainder (32-bit)
    signal cnt: unsigned(5 downto 0) := (others => '0');
    -- Signal for the result of subtraction
    signal sub : unsigned(32 downto 0);
              
begin

    
	quotient_OUT <= quotient;
	
	remainder_OUT <= remainder;
-----------------------------------------------------------------------------
-- FSM process new
-----------------------------------------------------------------------------	

    -- Control path: Registers of the FSM - NEW: added FIRRST and FIFORST
    process(FIFOCLK, reset)
    begin
        if (reset='1') then
            state_reg <= idle; -- Reset the FSM to idle state
            FIRRST <= '1'; -- NEW: Reset the FIR
            FIFORST <= '1'; -- NEW: Reset the FIFO
        elsif (FIFOCLK'event and FIFOCLK='1') then
            state_reg <= state_next; -- Update the state register
        end if;
    end process;


    -- Control path: Logic to determine the next state of the FSM
    process(state_reg, ena, FIFOWEN, FIRENA, FIFORST, FIFOFULL, FIFOEMPTY, FIRRST)
    begin
        case state_reg is 
            when idle => 
				-- else
				-- 	FIRIFG <= '0';
				-- end if;-- NEW: added firout_ready and fifoempty firifg logic, need to check if this is correct
                if (FIFOWEN='1') then
                    state_next <= STATE_FIFO; -- Move to STATE_FIFO state if FIFO ENABLED is asserted
                elsif (FIRENA = '1') then
                    state_next <= STATE_FIR; -- Move to STATE_FIR state if FIR ENABLED is asserted
                else
                    state_next <= idle; -- Stay in idle state if not started
                end if;
                        
            when STATE_FIFO =>
                if FIFORST = '1' or FIFOFULL = '1' then
                    state_next <= idle; -- Return to idle state when done   
                elsif FIRENA = '1' then
                    state_next <= STATE_FIR; -- Move to STATE_FIR state after STATE_FIFOing
                else
                    state_next <= STATE_FIFO; -- Continue STATE_FIFOing
                end if;
				-- if(i_reg = i_next) then --  HANAN turns of firifg in itcm line FIR_STP section
				-- 	FIRIFG <= '0';
				-- end if;
                
            when STATE_FIR =>
                if firout_ready = '1' or FIFOEMPTY = '1' then
                    FIRIFG <= '1';
                end if;
                
                -- need to verify logic for firifg_type
                if fifoempty = '1' then
                    FIRIFG_type <= "01";
                elsif firout_ready = '1' then
                    FIRIFG_type <= "10";
                else
                    FIRIFG_type <= "10";
                end if;

                if (FIRENA = '0') OR (FIRRST = '1') then
                    state_next <= idle; -- Return to idle state when done
                elsif FIFOEMPTY = '1' then
                    state_next <= idle; -- Continue STATE_FIFOing
                else
                    state_next <= STATE_FIR; -- Continue STATE_FIRing
                end if;
                
        end case;
    end process;
    
-----------------------------------------------------------------------------
-- UNUSED, HUSHED

    -- -- Control path: Registers for the counter used to count iterations -- UNUSED, HUSHED
    -- process(clk, reset)
    -- begin
    --     if (reset='1') then
    --         i_reg <= (others => '0'); -- Reset the iteration counter
    --     elsif (clk'event and clk='1') then
    --         i_reg <= i_next; -- Update iteration counter
    --     end if;
    -- end process;


    
    -- -- Control path: Logic for the iteration counter -- UNUSED, HUSHED
    -- process(state_reg, i_reg)
    -- begin
    --     case state_reg is
    --         when idle =>
    --             i_next <= (others => '0'); -- Initialize counter to zero in idle state
                
    --         when STATE_FIFO =>
    --             i_next <= i_reg; -- Keep counter value during STATE_FIFOing
                
    --         when STATE_FIR =>
    --             i_next <= i_reg + 1; -- Increment counter during STATE_FIR
    --     end case;
    -- end process;
        
    -- -- Data path: Registers used in the data path -- UNUSED, HUSHED
    -- process(clk, reset)
    -- begin
    --     if (reset='1') then
    --         z_reg <= (others => '0'); -- Reset the z register
    --         divisor_reg <= (others => '0'); -- Reset the d register
			
    --     elsif (clk'event and clk='1') then
    --         z_reg <= z_next; -- Update z register
    --         divisor_reg <= divisor_next; -- Update d register
    --     end if;
    -- end process;
    
    -- -- Data path: Multiplexers of the data path (handle register assignments based on FSM state) -- UNUSED, HUSHED
    -- process(state_reg, dividend, divisor, z_reg, divisor_reg, sub)
    -- begin
    --     divisor_next <= unsigned(divisor); -- Update divisor register
    --     case state_reg is
    --         when idle =>
    --             z_next <=   "000000000000000000000000000000000" & unsigned(dividend); -- Initialize z with dividend in idle state (upper 32 bits are zero)
                
    --         when STATE_FIFO =>
    --             z_next <= z_reg(63 downto 0) & '0'; -- STATE_FIFO left during STATE_FIFO state
                
    --         when STATE_FIR =>
    --             if (z_reg(63 downto 32) < divisor_reg) then
    --                 z_next <= z_reg; -- Keep z value if upper 32 bits are less than divisor
    --             else
    --                 z_next <= (z_reg(64 downto 32) - divisor_reg) & z_reg(31 downto 1) & '1'; -- Subtract divisor and update z with quotient bit
    --             end if;
    --     end case;
    -- end process;
    
    -- -- Data path: Functional units for subtraction -- UNUSED, HUSHED
    -- sub <= z_reg(64 downto 32) - divisor_reg; -- Perform subtraction STATE_FIR
    
    -- -- Data path: Output assignment
    -- quotient <= std_logic_vector(z_reg(31 downto 0)); -- Assign quotient output
    -- remainder <= std_logic_vector(z_reg(63 downto 32)); -- Assign remainder output
 -----------------------------------------------------------------------------   

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- sync clock process
-----------------------------------------------------------------------------
    -------------------------------------------------------------------------
    -- FIRCLK domain: generate a toggle signal every FIRCLK when FIRENA=1
    -------------------------------------------------------------------------
    process(FIRCLK, FIRRST)
    begin
        if FIRRST = '1' then
            fir_pulse <= '0';
        elsif rising_edge(FIRCLK) then
            if FIRENA = '1' then
                fir_pulse <= not fir_pulse;  -- toggle each FIRCLK
            else
                fir_pulse <= '0';
            end if;
        end if;
    end process;

    -------------------------------------------------------------------------
    -- FIFOCLK domain: sync toggle into FIFOCLK and detect edges -> FIFOREN
    -------------------------------------------------------------------------
    process(FIFOCLK, FIFORST)
    begin
        if FIFORST = '1' then
            sync_ff1 <= '0';
            sync_ff2 <= '0';
            FIFOREN  <= '0';
        elsif rising_edge(FIFOCLK) then
            sync_ff1 <= fir_pulse;
            sync_ff2 <= sync_ff1;
            -- edge detect: pulse when fir_pulse toggles
            FIFOREN <= sync_ff1 xor sync_ff2;
        end if;
    end process;


-----------------------------------------------------------------------------
-- fifo state process
-----------------------------------------------------------------------------

    -----------------------------------------------------------------
    -- 1. FIFO write process
    -----------------------------------------------------------------
    process(FIFOCLK, reset, FIFOWEN)
    begin
        if reset = '1' then
            fifo_wr_ptr   <= 0;
            fifo_count_wr <= 0;
            
        elsif rising_edge(FIFOCLK) then
            if FIRCTL(5) = '1' and fifo_count < k then
                fifo_memory(fifo_wr_ptr) <= FIRIN(W-1 downto 0);
                fifo_wr_ptr   <= (fifo_wr_ptr + 1) mod k;
                fifo_count_wr <= fifo_count_wr + 1;

                -- auto clear control bit after use
                FIRCTL_internal(5) <= '0';
            end if;
        end if;
    end process;

    -----------------------------------------------------------------
    -- 2. FIFO count (synchronous update)
    -----------------------------------------------------------------
    process(FIFOCLK, FIFORST)
    begin
        if FIFORST = '1' then
            fifo_count <= 0;
            FIFOEMPTY <= '1';
            FIFOFULL  <= '0';
        elsif rising_edge(FIFOCLK) then
            fifo_count <= fifo_count_wr - fifo_count_rd;
            FIFOEMPTY <= '1' when fifo_count = 0 else '0';
            FIFOFULL  <= '1' when fifo_count = k else '0';
        end if;
    end process;

-----------------------------------------------------------------------------
-- fir state process
-----------------------------------------------------------------------------
    -----------------------------------------------------------------
    -- 1. fir read from FIFO process
    -----------------------------------------------------------------
    process(FIFOCLK, FIRRST)
    begin
        if FIRRST = '1' then
            fifo_rd_ptr   <= 0;
            x_input       <= (others => '0');
            fifo_count_rd <= 0;
        elsif rising_edge(FIFOCLK) then
            if FIFOREN = '1' and fifo_count > 0 then
                x_input       <= fifo_memory(fifo_rd_ptr);
                fifo_rd_ptr   <= (fifo_rd_ptr + 1) mod k;
                fifo_count_rd <= fifo_count_rd + 1;
                
            end if;
        end if;
    end process;

    -----------------------------------------------------------------
    -- 2. FIR filter processing
    -----------------------------------------------------------------
    process(FIRCLK, FIRRST)
        variable temp_sum : signed(55 downto 0);
        variable temp_mul : signed(55 downto 0);
    begin
        if FIRRST = '1' then
            x_delay <= (others => (others => '0'));
            y_output <= (others => '0');
            processing_active <= '0';
            firout_ready <= '0';
        elsif rising_edge(FIRCLK) then
            if FIRENA = '1'  then
                -- shift delay line
                for i in M-1 downto 1 loop
                    x_delay(i) <= x_delay(i-1);
                end loop;
                x_delay(0) <= x_input;
                
                -- FIR computation
                temp_sum := (others => '0');
                for i in 0 to M-1 loop
                    temp_mul := signed(x_delay(i)) * signed(coefficients(i));
                    temp_sum := temp_sum + temp_mul;
                end loop;
                -- take upper 32 bits
                y_output <= std_logic_vector(temp_sum(55 downto 24));
                firout_ready <= '1';
                processing_active <= '1';
            else
                processing_active <= '0';
                firout_ready <= '0';
            end if;
        end if;
    end process;


    
--------------------------------------------------
-- FIR Control Register bit assignments based on FIRCTL
--------------------------------------------------

    -- Update the interrupt flag register based on data from the MCU or the IRQ sources
    FIRCTL		<=	DataBus(7 DOWNTO 0)	WHEN (Addr = X"82C" AND FIRCTLwrite = '1') ELSE
    FIRCTL_internal;

        -- Provide data to the MCU on the data bus based on the address and read signals
    DataBus <= "000000000000000000000000"	& FIRCTL_internal	WHEN (Addr = X"82C" AND FIRCTLread = '1') ELSE
    (OTHERS => 'Z'); 


    PROCESS(FIFOCLK, reset)
    BEGIN
        IF reset = '1' THEN
            FIRCTL_internal <= (OTHERS => '0');
        ELSIF rising_edge(FIFOCLK) THEN
            -- Copy specific bits from FIRCTL to FIRCTL_internal
            FIRCTL_internal(0) <= FIRCTL(0);  -- FIR Enable
            FIRCTL_internal(1) <= FIRCTL(1);  -- FIR Reset
            FIRCTL_internal(2) <= FIFOFULL;   -- FIFO Full status flag
            FIRCTL_internal(3) <= FIFOEMPTY; -- FIFO Empty status flag
            FIRCTL_internal(4) <= FIRCTL(4);  -- FIFO Reset
            FIRCTL_internal(5) <= FIRCTL(5);  -- FIFO Write Enable

            -- Bits 2,3 are read-only (FIFO status)
            
            -- Bits 6,7 are unused
        END IF;
    END PROCESS;
    FIROUT <= y_output;
     -----------------------------------------------------------------
    -- Load coefficients
    -----------------------------------------------------------------
    coefficients(0) <= (23 downto 0 => '0') & COEF0;
    coefficients(1) <= (23 downto 0 => '0') & COEF1;
    coefficients(2) <= (23 downto 0 => '0') & COEF2;
    coefficients(3) <= (23 downto 0 => '0') & COEF3;
    coefficients(4) <= (23 downto 0 => '0') & COEF4;
    coefficients(5) <= (23 downto 0 => '0') & COEF5;
    coefficients(6) <= (23 downto 0 => '0') & COEF6;
    coefficients(7) <= (23 downto 0 => '0') & COEF7;
       
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE work.aux_package.ALL;
-----------------------------------------
-- Entity Declaration for FIR
-----------------------------------------
entity FIR is
    Port (
--------------------------------------------------
    -- fir interface ALREADY USED
        FIRCLK     : in STD_LOGIC;          -- Clock signal
        FIFOCLK     : in STD_LOGIC;          -- Clock signal
		Addr	: IN	STD_LOGIC_VECTOR(11 DOWNTO 0);
        reset   : in STD_LOGIC;        -- Asynchronous reset signal
        ena     : in STD_LOGIC;        -- Start signal to begin the fir
        FIRIFG  : buffer STD_LOGIC := '0';       
        FIRIFG_type : out STD_LOGIC_VECTOR(1 DOWNTO 0) := "00"; 
        DataBus		: INOUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- FIR control register is now inout
        FIRCTL     : buffer STD_LOGIC_VECTOR(7 downto 0):= (others => '0');
        INTR       : in STD_LOGIC;
        INTR_Active : in STD_LOGIC;
        -- Data interface
        FIRIN    : in  STD_LOGIC_VECTOR(31 downto 0);   -- FIR input data
        FIROUT   : buffer STD_LOGIC_VECTOR(31 downto 0) := (others => '0');   -- FIR output data


        -- Coefficient interface
        COEF0,COEF1,COEF2,COEF3,
        COEF4,COEF5,COEF6,COEF7 : in STD_LOGIC_VECTOR(7 downto 0);  -- added for fir!
--------------------------------------------------

--------------------------------------------------
        FIRCTLread	: IN	STD_LOGIC;
        FIRCTLwrite	: IN	STD_LOGIC
--------------------------------------------------
    );
end FIR;
----------------------------------------
-- Architecture Definition
----------------------------------------
architecture Behavioral of FIR is

    -- Define the states for the Finite State Machine (FSM)
    type state_type is (idle, STATE_FIFO, STATE_FIR);
    -- Add FSM state type and signals
    type firctl_state_type is (IDLE_FIRCTL, LOAD_FROM_DATABUS, MODIFY_FIRCTL);
    signal firctl_state, firctl_next_state : firctl_state_type;

    -- Constants for FIR
    constant M : integer := 8;  -- Number of filter taps
    constant W : integer := 24; -- Data width
    constant k : integer := 8;  -- FIFO depth parameter
    type coeff_array is array (0 to M-1) of STD_LOGIC_VECTOR(31 downto 0);
    type fifo_array is array (0 to k-1) of STD_LOGIC_VECTOR(W-1 downto 0);
    type delay_line is array (0 to M-1) of STD_LOGIC_VECTOR(W-1 downto 0);
    -- FIR signals
--------------------------------------------------
    signal databus_buffer : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    SIGNAL FIFOREN  : STD_LOGIC := '0'; -- added for fir!
    signal fifowen_internal : STD_LOGIC := '0'; -- added for fir!
    signal FIRCTL_internal : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); -- added for fir!
    signal coefficients   : coeff_array := (others => (others => '0'));
    SIGNAL y_counter : unsigned(5 DOWNTO 0) := (others => '0'); -- added for fir!
    signal firout_ready : STD_LOGIC := '0'; -- added for fir!
    signal fifoempty : STD_LOGIC := '0';
    signal fifofull : STD_LOGIC := '0';
    -- Processing signals
    signal x_input        : STD_LOGIC_VECTOR(W-1 downto 0) := (others => '0');
    signal y_output       : STD_LOGIC_VECTOR(31 downto 0)  := (others => '0');
    signal processing_active : STD_LOGIC := '0';
    signal x_delay : delay_line := (others => (others => '0'));
    signal temp_sum : unsigned(55 downto 0) := (others => '0');
    signal temp_mul : unsigned(55 downto 0) := (others => '0');
    signal prev_firout : unsigned(55 downto 0) := (others => '0');
--------------------------------------------------
    -- FIFO signals
    signal fifo_memory    : fifo_array := (others => (others => '0'));
    signal fifo_wr_ptr    : integer range 0 to k := 0;
    signal fifo_rd_ptr    : integer range 0 to k := 0;
    signal fifo_count_wr  : integer range 0 to k := 0;
    signal fifo_count_rd  : integer range 0 to k := 0;
    signal fifo_count     : integer range 0 to k;
--------------------------------------------------
    -- Synchronizer signals for FIR -> FIFO pulse
    signal fir_pulse   : std_logic := '0';
    signal sync_ff1    : std_logic := '0';
    signal sync_ff2    : std_logic := '0';
    signal sync_ff3    : std_logic := '0';  -- For FIFO->FIR handshake
    signal sync_ff4    : std_logic := '0';  -- For FIFO->FIR handshake

--------------------------------------------------
    -- Alias for FIRCTL bits
    alias FIRENA is FIRCTL(0);
    alias FIRRST is FIRCTL(1);
    alias FIFORST is FIRCTL(4);
    alias FIFOWEN is FIRCTL(5);
    
    
    
    
    
    -- Signals for FSM state registers and next state values
    signal state_reg, state_next : state_type;   
    signal cnt: unsigned(5 downto 0) := (others => '0');

              
begin


-----------------------------------------------------------------------------
-- FSM process new
-----------------------------------------------------------------------------	

    -- Control path: Registers of the FSM - NEW: added FIRRST and FIFORST
    process(FIFOCLK, reset)
    begin
        if (reset='1') then
            state_reg <= idle; -- Reset the FSM to idle state
        elsif (FIFOCLK'event and FIFOCLK='1') then
            state_reg <= state_next; -- Update the state register
        end if;
    end process;


    process(FIFOCLK, reset)
    begin
        if reset = '1' then
            firifg <= '0';
            FIRIFG_type <= "00";
        elsif rising_edge(FIFOCLK) then
            if FIFOEMPTY = '1' or firout_ready = '1' then
                firifg <= '1';
            else
                firifg <= '0';
            end if;
            -- need to verify logic for firifg_type
            if fifoempty = '1' then
                FIRIFG_type <= "01";
            elsif firout_ready = '1' then
                FIRIFG_type <= "10";
  --          else
    --            FIRIFG_type <= "00";
            end if;
        end if;
    end process;
    
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
    --1.  FIFO count (synchronous update)
    -----------------------------------------------------------------
    process(FIFOCLK, FIFORST)
    begin
        if FIFORST = '1' then
            fifo_count <= 0;
        elsif rising_edge(FIFOCLK) then
            -- Proper FIFO count calculation using modulo arithmetic
            if fifo_count_wr >= fifo_count_rd then
                fifo_count <= fifo_count_wr - fifo_count_rd;
            else
                -- Handle wrap-around case: (k+1) - (fifo_count_rd - fifo_count_wr)
                fifo_count <= (k+1) - (fifo_count_rd - fifo_count_wr);
            end if;
        end if;
        if fifo_count = 0 and FIRCTL(0) = '1' and FIFOREN = '1' then
            fifoempty <= '1';
        else
            fifoempty <= '0';
        end if;
        if fifo_count = k-1 then
            fifofull <= '1';
        else
            fifofull <= '0';
        end if;
    end process;

    -----------------------------------------------------------------
    -- 2. FIFO write process
    -----------------------------------------------------------------
    process(FIFOCLK, FIFORST)
    begin
        if FIFORST = '1' then
            fifo_wr_ptr   <= 0;
            fifo_count_wr <= 0;

        elsif rising_edge(FIFOCLK) then
            if FIFOWEN = '1' and fifo_count < k then
                fifo_memory(fifo_wr_ptr) <= FIRIN(W-1 downto 0);
                fifo_wr_ptr   <= (fifo_wr_ptr + 1) mod k;
                fifo_count_wr <= (fifo_count_wr + 1) mod (k+1);
            end if;
        end if;
    end process;
    
-----------------------------------------------------------------------------
-- fir state process

-----------------------------------------------------------------------------
-- FIR filter processing
-----------------------------------------------------------------------------
process(FIFOCLK, FIRRST)
    variable delay_var : delay_line;               -- local variable for delay line
    variable sum_var   : unsigned(55 downto 0);      -- local accumulator
    variable new_sample : STD_LOGIC_VECTOR(W-1 downto 0);
    variable first_sample_loaded : STD_LOGIC := '0';
    variable final_x_delay : STD_LOGIC_VECTOR(W-1 downto 0);
    
begin
    if FIRRST = '1' then
        -- Reset all states
        x_delay           <= (others => (others => '0'));
        y_output          <= (others => '0');
        processing_active <= '0';
        firout_ready      <= '0';
        fifo_rd_ptr       <= 0;
        x_input           <= (others => '0');
        fifo_count_rd     <= 0;
        temp_sum          <= (others => '0');
        temp_mul          <= (others => '0');
        prev_firout       <= (others => '0');

    elsif rising_edge(FIFOCLK) then
        if FIFOREN = '1' and fifoempty = '0' then
            -- Copy signals into local variable for immediate update
            delay_var := x_delay;
            fifo_rd_ptr   <= (fifo_rd_ptr + 1) mod k;
            fifo_count_rd <= (fifo_count_rd + 1) mod (k+1);
            -- Capture new sample from FIFO into a variable
            new_sample := fifo_memory(fifo_rd_ptr);

            -- Update FIFO pointers


            -- Shift delay line (older samples move right)
            for i in M-1 downto 1 loop
                delay_var(i) := delay_var(i-1);
            end loop;
            delay_var(0) := new_sample;

            -- FIR computation using the updated delay line
            sum_var := (unsigned(delay_var(0)) * unsigned(coefficients(0))) +
                       (unsigned(delay_var(1)) * unsigned(coefficients(1))) +
                       (unsigned(delay_var(2)) * unsigned(coefficients(2))) +
                       (unsigned(delay_var(3)) * unsigned(coefficients(3))) + 
                       (unsigned(delay_var(4)) * unsigned(coefficients(4))) +
                       (unsigned(delay_var(5)) * unsigned(coefficients(5))) +
                       (unsigned(delay_var(6)) * unsigned(coefficients(6))) +
                       (unsigned(delay_var(7)) * unsigned(coefficients(7)));
            final_x_delay := delay_var(7);
            -- Commit updated delay line and sample to signals
            x_delay <= delay_var;
            x_input <= new_sample;

            -- Save sum into signal for waveform visibility
            temp_sum <= sum_var;

            -- Output result immediately (zero-extended to 32 bits)
            y_output <= "00000000" & std_logic_vector(sum_var(31 downto 8));
            FIROUT   <= "00000000" & std_logic_vector(sum_var(31 downto 8));


            -- Flags
            if sum_var /= "00000000000000000000000000000000000000000000000000000000" then
                firout_ready      <= '1';
                processing_active <= '1';
            else
                fifo_rd_ptr   <= (fifo_rd_ptr - 1) mod k;
                fifo_count_rd <= (fifo_count_rd - 1) mod (k+1);
                for i in M-1 downto 1 loop
                    delay_var(i-1) := delay_var(i);
                end loop;
                delay_var(7) := final_x_delay;
            end if;
            
            -- Store current output for next comparison
            prev_firout <= sum_var;

        else
            -- Pause FIR when FIFO is empty
            processing_active <= '0';
            firout_ready      <= '0';
        end if;
    end if;
end process;



-----------------------------------------------------------------------------
-- firctl fsm control process
----------------------------------------------------------------------------- 
    -- Provide data to the MCU on the data bus based on the address and read signals
    DataBus <= "000000000000000000000000"	& FIRCTL	WHEN (Addr = X"82C" AND FIRCTLread = '1' and INTR = '0' and INTR_Active = '0') ELSE
    FIROUT	WHEN (Addr = X"834" AND FIRCTLread = '1') ELSE
    (OTHERS => 'Z'); 

    process(FIFOCLK, reset,addr,FIRCTLwrite,fifowen,fifo_count)
        begin
            if (Addr = X"82C" AND FIRCTLwrite = '1') THEN
                FIRCTL(7 downto 4) <= DataBus(7 downto 4);
                FIRCTL(1 downto 0) <= DataBus(1 downto 0);
            elsif (FIFOWEN = '1' OR (firctl(2) = '0' AND fifo_count = 0) OR (firctl(3) = '0' AND fifo_count = k)) THEN
                -- Modify specific bits based on conditions
                FIRCTL(2) <= fifoempty;  -- FIFO Full
                FIRCTL(3) <= fifofull;  -- FIFO Empty
                -- FIRCTL(5) logic for FIFO write process
                FIRCTL(5) <= '0';
            end if;
        end process;

    -- FIROUT is now assigned inside the process for immediate update
    
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

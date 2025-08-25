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

        -- Data interface
        FIRIN    : in  STD_LOGIC_VECTOR(31 downto 0);   -- FIR input data
        FIROUT   : buffer STD_LOGIC_VECTOR(31 downto 0) := (others => '1');   -- FIR output data


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


<<<<<<< HEAD:DUT/FIR.vhd
    -- -- Control path: Logic to determine the next state of the FSM
=======
    -- Control path: Logic to determine the next state of the FSM
>>>>>>> 818fb9a182e484e0e3b60d66e0c03861e4f29830:DUT/my_divider.vhd
    -- process(state_reg, ena, FIFOWEN, FIRENA, FIFORST, FIFOFULL, FIFOEMPTY, FIRRST)
    -- begin
    --     case state_reg is 
    --         when idle => 
	-- 			-- else
	-- 			-- 	FIRIFG <= '0';
	-- 			-- end if;-- NEW: added firout_ready and fifoempty firifg logic, need to check if this is correct
    --             if (FIFOWEN='1') then
    --                 state_next <= STATE_FIFO; -- Move to STATE_FIFO state if FIFO ENABLED is asserted
    --             elsif (FIFOREN = '1') then
    --                 state_next <= STATE_FIR; -- Move to STATE_FIR state if FIR ENABLED is asserted
    --             else
    --                 state_next <= idle; -- Stay in idle state if not started
    --             end if;
                        
    --         when STATE_FIFO =>
    --             if FIFORST = '1' or FIFOFULL = '1' then
    --                 state_next <= idle; -- Return to idle state when done   
<<<<<<< HEAD:DUT/FIR.vhd
    --             elsif FIRENA = '1' then
=======
    --             elsif FIFOREN = '1' then
>>>>>>> 818fb9a182e484e0e3b60d66e0c03861e4f29830:DUT/my_divider.vhd
    --                 state_next <= STATE_FIR; -- Move to STATE_FIR state after STATE_FIFOing
    --             else
    --                 state_next <= STATE_FIFO; -- Continue STATE_FIFOing
    --             end if;
<<<<<<< HEAD:DUT/FIR.vhd
	-- 			-- if(i_reg = i_next) then --  HANAN turns of firifg in itcm line FIR_STP section
	-- 			-- 	FIRIFG <= '0';
	-- 			-- end if;
=======
>>>>>>> 818fb9a182e484e0e3b60d66e0c03861e4f29830:DUT/my_divider.vhd
                
    --         when STATE_FIR =>

    --             if firout_ready = '1' or FIFOEMPTY = '1' then
    --                 FIRIFG <= '1';
    --             end if;
                
    --             -- need to verify logic for firifg_type
<<<<<<< HEAD:DUT/FIR.vhd
    --             if fifoempty = '1' then
    --                 FIRIFG_type <= "01";
    --             elsif firout_ready = '1' then
    --                 FIRIFG_type <= "10";
    --             else
    --                 FIRIFG_type <= "00";
    --             end if;

    --             if (FIRENA = '0') OR (FIRRST = '1') then
    --                 state_next <= idle; -- Return to idle state when done
    --             elsif FIFOEMPTY = '1' and firout_ready = '1' then
    --                 state_next <= idle; -- Continue STATE_FIFOing
    --             elsif FIFOWEN = '1' then
    --                 state_next <= STATE_FIFO;
    --             else
    --                 state_next <= STATE_FIR; -- Continue STATE_FIRing
    --             end if;
                
    --     end case;
    -- end process;

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
=======
    process(FIFOCLK, reset)
    begin
        if reset = '1' then
            FIRIFG_type <= "00";
        elsif rising_edge(FIFOCLK) then
>>>>>>> 818fb9a182e484e0e3b60d66e0c03861e4f29830:DUT/my_divider.vhd
            if fifoempty = '1' then
                FIRIFG_type <= "01";
            elsif firout_ready = '1' then
                FIRIFG_type <= "10";
<<<<<<< HEAD:DUT/FIR.vhd
  --          else
    --            FIRIFG_type <= "00";
=======
            else
                FIRIFG_type <= "00";
>>>>>>> 818fb9a182e484e0e3b60d66e0c03861e4f29830:DUT/my_divider.vhd
            end if;
        end if;
    end process;

    FIRIFG <= FIRENA and (firout_ready or fifoempty);

    --             if (FIRENA = '0') OR (FIRRST = '1') then
    --                 state_next <= idle; -- Return to idle state when done
    --             elsif FIFOEMPTY = '1' and firout_ready = '1' then
    --                 state_next <= idle; -- Continue STATE_FIFOing
    --             elsif FIFOWEN = '1' then
    --                 state_next <= STATE_FIFO;
    --             else
    --                 state_next <= STATE_FIR; -- Continue STATE_FIRing
    --             end if;
                
    --     end case;
    -- end process;
    
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
            if fifo_count_rd > fifo_count_wr then
                fifo_count <= fifo_count_wr - (fifo_count_rd) mod (k);
            else    
                fifo_count <= fifo_count_wr - fifo_count_rd;
            end if;
        end if;
        if fifo_count = 0 then
            fifoempty <= '1';
        else
            fifoempty <= '0';
        end if;
        if fifo_count = k then
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
                --fifo_memory(fifo_rd_ptr) <= (others => '0');
                fifo_rd_ptr   <= (fifo_rd_ptr + 1) mod k;
                fifo_count_rd <= (fifo_count_rd + 1) mod (k+1);

                
            end if;
        end if;
        --IF fifo_count_rd = fifo_count_wr THEN
         --   fifo_count_rd <= 0;
        ---END IF;
    end process;

    -----------------------------------------------------------------
    -- 2. FIR filter processing
    -----------------------------------------------------------------
    process(FIFOCLK, FIRRST)
        variable temp_sum : signed(55 downto 0);
        variable temp_mul : signed(55 downto 0);
    begin
        if FIRRST = '1' then
            x_delay <= (others => (others => '0'));
            y_output <= (others => '0');
            processing_active <= '0';
            firout_ready <= '0';
        elsif rising_edge(FIFOCLK) then
            if FIFOREN = '1' then
                -- shift delay line
                for i in M-1 downto 1 loop
<<<<<<< HEAD:DUT/FIR.vhd
                    
=======
                    --report "inside FIR loop!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!";
>>>>>>> 818fb9a182e484e0e3b60d66e0c03861e4f29830:DUT/my_divider.vhd
                    x_delay(i) <= x_delay(i-1);
                end loop;
                x_delay(0) <= x_input;
                
                -- FIR computation
                temp_sum := (others => '0');
                for i in 0 to M-1 loop
                    temp_mul := signed(x_delay(i)) * signed(coefficients(i));
                    temp_sum := temp_sum + temp_mul;
                    report "temp_sum: " & integer'image(to_integer(temp_sum));
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

-----------------------------------------------------------------------------
-- firctl fsm control process
----------------------------------------------------------------------------- 
    -- Provide data to the MCU on the data bus based on the address and read signals
    DataBus <= "000000000000000000000000"	& FIRCTL	WHEN (Addr = X"82C" AND FIRCTLread = '1') ELSE
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

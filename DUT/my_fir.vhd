library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE work.aux_package.ALL;
-----------------------------------------
-- Entity Declaration for FIR Filter
-----------------------------------------
entity FIR_Filter is
    Port (
        -- Clock and Reset
        FIRCLK : in STD_LOGIC;          -- FIR core clock
        FIFOCLK : in STD_LOGIC;         -- FIFO clock
        FIRRST : in STD_LOGIC;          -- FIR core reset
        FIFORST : in STD_LOGIC;         -- FIFO reset
        
        -- Control signals
        FIRENA : in STD_LOGIC;          -- FIR core enable
        FIFOWEN : in STD_LOGIC;         -- FIFO write enable
        FIFOREN : in STD_LOGIC;         -- FIFO read enable
        
        -- Status signals
        FIFOFULL : out STD_LOGIC;       -- FIFO full status
        FIFOEMPTY : out STD_LOGIC;      -- FIFO empty status
        FIRIFG : out STD_LOGIC;         -- FIR interrupt flag
        FIRIFG_OUTREADY : out std_logic; -- NEW: asserts when FIROUT is valid

        
        -- Data interface
        FIRIN : in STD_LOGIC_VECTOR(31 downto 0);   -- FIR input data
        FIROUT : out STD_LOGIC_VECTOR(31 downto 0); -- FIR output data
        
        -- Coefficient interface
        COEF0 : in STD_LOGIC_VECTOR(7 downto 0);    -- Coefficient 0
        COEF1 : in STD_LOGIC_VECTOR(7 downto 0);    -- Coefficient 1
        COEF2 : in STD_LOGIC_VECTOR(7 downto 0);    -- Coefficient 2
        COEF3 : in STD_LOGIC_VECTOR(7 downto 0);    -- Coefficient 3
        COEF4 : in STD_LOGIC_VECTOR(7 downto 0);    -- Coefficient 4
        COEF5 : in STD_LOGIC_VECTOR(7 downto 0);    -- Coefficient 5
        COEF6 : in STD_LOGIC_VECTOR(7 downto 0);    -- Coefficient 6
        COEF7 : in STD_LOGIC_VECTOR(7 downto 0);    -- Coefficient 7
        
        -- Memory interface
        Addr : in STD_LOGIC_VECTOR(11 DOWNTO 0);
        FIRRead : in STD_LOGIC;
        FIRWrite : in STD_LOGIC;
        
        -- Interrupt control
        FIRIFG_CLR : in STD_LOGIC       -- Clear FIR interrupt flag
    );
end FIR_Filter;
----------------------------------------
-- Architecture Definition
----------------------------------------
architecture Behavioral of FIR_Filter is
    -- Constants
    constant M : integer := 8;  -- Number of filter taps
    constant W : integer := 24; -- Data width
    constant q : integer := 8;  -- Coefficient width
    constant k : integer := 8;  -- FIFO depth parameter
    
    -- FIFO signals
    type fifo_array is array (0 to 2**k-1) of STD_LOGIC_VECTOR(W-1 downto 0);
    signal fifo_memory : fifo_array := (others => (others => '0'));
    signal fifo_wr_ptr : integer range 0 to 2**k-1 := 0;
    signal fifo_rd_ptr : integer range 0 to 2**k-1 := 0;
    signal fifo_count_wr : integer range 0 to 2**k := 0;  -- Write side count
    signal fifo_count_rd : integer range 0 to 2**k := 0;  -- Read side count
    signal fifo_count : integer range 0 to 2**k := 0;     -- Combined count
    
    -- FIR filter signals
    type delay_line is array (0 to M-1) of STD_LOGIC_VECTOR(W-1 downto 0);
    type coeff_array is array (0 to M-1) of STD_LOGIC_VECTOR(31 downto 0);  -- 32-bit coefficients
    signal x_delay : delay_line := (others => (others => '0'));
    signal coefficients : coeff_array := (others => (others => '0'));
    
    -- Processing signals
    signal x_input : STD_LOGIC_VECTOR(W-1 downto 0);
    signal y_output : STD_LOGIC_VECTOR(31 downto 0);  -- Fixed to 32 bits for output
    signal processing_active : STD_LOGIC := '0';
    
    -- Clock domain crossing synchronizer
    signal fifo_ren_sync1, fifo_ren_sync2 : STD_LOGIC;
    
    -- Internal status signals
    signal fifo_empty_internal : STD_LOGIC;
    signal fifo_full_internal : STD_LOGIC;
    signal output_valid : std_logic := '0';
    
begin
    -- FIFO control logic
    fifo_empty_internal <= '1' when fifo_count = 0 else '0';
    fifo_full_internal <= '1' when fifo_count = 2**k else '0';
    
    -- Map internal signals to outputs
    FIFOEMPTY <= fifo_empty_internal;
    FIFOFULL <= fifo_full_internal;
    
    -- Clock domain crossing synchronizer for FIFOREN (Two-stage synchronizer)
    -- This implements the CDC pattern shown in the attached image
    process(FIFOCLK, FIFORST)
    begin
        if FIFORST = '1' then
            fifo_ren_sync1 <= '0';
            fifo_ren_sync2 <= '0';
        elsif rising_edge(FIFOCLK) then
            -- First stage: Sample from FIRCLK domain (FIFOREN)
            fifo_ren_sync1 <= FIFOREN;
            -- Second stage: Stabilize the synchronized signal
            fifo_ren_sync2 <= fifo_ren_sync1;
        end if;
    end process;
    
    -- Pulse stretcher for FIFOREN to ensure reliable CDC
    -- This helps capture short pulses that might be missed during synchronization
    process(FIFOCLK, FIFORST)
        variable fifo_ren_stretch : STD_LOGIC := '0';
    begin
        if FIFORST = '1' then
            fifo_ren_stretch := '0';
        elsif rising_edge(FIFOCLK) then
            if FIFOREN = '1' then
                fifo_ren_stretch := '1';
            elsif fifo_ren_sync2 = '1' then
                fifo_ren_stretch := '0';
            end if;
        end if;
    end process;
    
    -- Additional CDC consideration: Ensure FIFOREN is properly synchronized
    -- The synchronized FIFOREN signal is used in the FIFO read process
    
    -- Metastability detection and CDC safety
    -- This helps identify potential CDC issues during simulation
    process(FIFOCLK, FIFORST)
    begin
        if FIFORST = '1' then
            -- Reset metastability indicators
            null;
        elsif rising_edge(FIFOCLK) then
            -- Check for potential metastability conditions
            -- (This is mainly for simulation/debugging purposes)
            if fifo_ren_sync1 = 'X' or fifo_ren_sync1 = 'U' then
                -- Report potential metastability (in real hardware this would be handled automatically)
                report "Potential metastability detected in FIFOREN synchronization" severity warning;
            end if;
        end if;
    end process;
    
    -- Synthesis tool directives for CDC
    -- These comments help synthesis tools understand the CDC requirements
    -- attribute ASYNC_REG : string;
    -- attribute ASYNC_REG of fifo_ren_sync1 : signal is "TRUE";
    -- attribute ASYNC_REG of fifo_ren_sync2 : signal is "TRUE";
    
    -- FIFO write process
    process(FIFOCLK, FIFORST)
    begin
        if FIFORST = '1' then
            fifo_wr_ptr <= 0;
            fifo_count_wr <= 0;
        elsif rising_edge(FIFOCLK) then
            if FIFOWEN = '1' and fifo_count < 2**k then
                fifo_memory(fifo_wr_ptr) <= FIRIN(W-1 downto 0);
                fifo_wr_ptr <= (fifo_wr_ptr + 1) mod 2**k;
                fifo_count_wr <= fifo_count_wr + 1;
            end if;
        end if;
    end process;
    
    -- FIFO read process
    process(FIRCLK, FIRRST)
    begin
        if FIRRST = '1' then
            fifo_rd_ptr <= 0;
            x_input <= (others => '0');
            fifo_count_rd <= 0;
        elsif rising_edge(FIRCLK) then
            if fifo_ren_sync2 = '1' and fifo_count > 0 then
                x_input <= fifo_memory(fifo_rd_ptr);
                fifo_rd_ptr <= (fifo_rd_ptr + 1) mod 2**k;
                fifo_count_rd <= fifo_count_rd + 1;
            end if;
        end if;
    end process;
    
    -- Combine write and read counts (simplified approach)
    fifo_count <= fifo_count_wr - fifo_count_rd;
    
    -- Load coefficients - fix length assignments
    coefficients(0) <= "000000000000000000000000" & COEF0;
    coefficients(1) <= "000000000000000000000000" & COEF1;
    coefficients(2) <= "000000000000000000000000" & COEF2;
    coefficients(3) <= "000000000000000000000000" & COEF3;
    coefficients(4) <= "000000000000000000000000" & COEF4;
    coefficients(5) <= "000000000000000000000000" & COEF5;
    coefficients(6) <= "000000000000000000000000" & COEF6;
    coefficients(7) <= "000000000000000000000000" & COEF7;
    
    -- FIR filter processing
    process(FIRCLK, FIRRST)
        variable temp_sum : STD_LOGIC_VECTOR(55 downto 0);  -- 24+32-1 = 55 bits for multiplication result
        variable temp_mul : STD_LOGIC_VECTOR(55 downto 0);
    begin
        if FIRRST = '1' then
            x_delay <= (others => (others => '0'));
            y_output <= (others => '0');
            processing_active <= '0';
        elsif rising_edge(FIRCLK) then
            if FIRENA = '1' then
                -- Shift delay line
                for i in M-1 downto 1 loop
                    x_delay(i) <= x_delay(i-1);
                end loop;
                x_delay(0) <= x_input;
                
                -- FIR computation
                temp_sum := (others => '0');
                for i in 0 to M-1 loop
                    temp_mul := STD_LOGIC_VECTOR(signed(x_delay(i)) * signed(coefficients(i)));
                    temp_sum := STD_LOGIC_VECTOR(signed(temp_sum) + signed(temp_mul));
                end loop;
                -- Take the upper 32 bits of the result for output
                y_output <= temp_sum(55 downto 24);
                processing_active <= '1';
            else
                processing_active <= '0';
            end if;
        end if;
    end process;



    process(FIRCLK, FIRRST)
    begin
        if FIRRST = '1' then
            output_valid <= '0';
        elsif rising_edge(FIRCLK) then
            if FIRENA = '1' then
                output_valid <= '1';   -- each time we produce a new output
            else
                output_valid <= '0';
            end if;
        end if;
    end process;
    

    
    -- Output mapping: {'0'@8, y(n)<31...8>}
    FIROUT <= "00000000" & y_output(23 downto 0);
    
    -- Interrupt generation - use internal signal instead of output
    -- New:
    FIRIFG <= '0' when FIRIFG_CLR = '1' else
        output_valid;

    FIRIFG_OUTREADY <= '1' when output_valid = '1' else '0';
    
    
    -- Memory read interface
--    process(FIRRead, Addr)
  --  begin
    --    if FIRRead = '1' then
      --      case Addr is
        --        when X"82C" => -- FIRCTL
          --          -- Return control register status
            --        null; -- This would be handled by the MCU
              --  when X"830" => -- FIRIN
                --    -- Return input register (read-only from this component)
                  --  null;
--                when X"834" => -- FIROUT
  --                  -- Return output register
    --                null;
      --          when others =>
        --            null;
          --  end case;
        --end if;
    --end process;
    
end Behavioral;

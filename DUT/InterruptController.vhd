LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.aux_package.ALL;

-----------------------------------------
-- Entity Declaration for INTERRUPT
-----------------------------------------
ENTITY INTERRUPT IS
    GENERIC(
        DataBusSize : integer := 32;
        AddrBusSize : integer := 12;
        IrqSize     : integer := 8;
        RegSize     : integer := 8
    );
    PORT(
        reset       : IN    STD_LOGIC;
        clock       : IN    STD_LOGIC;
        MemReadBus  : IN    STD_LOGIC;
        MemWriteBus : IN    STD_LOGIC;
        AddressBus  : IN    STD_LOGIC_VECTOR(AddrBusSize-1 DOWNTO 0);
        DataBus     : INOUT STD_LOGIC_VECTOR(DataBusSize-1 DOWNTO 0);
        IntrSrc     : IN    STD_LOGIC_VECTOR(7 DOWNTO 0); -- IRQ sources
        ChipSelect  : IN    STD_LOGIC;
        INTR        : OUT   STD_LOGIC;
        INTA        : IN    STD_LOGIC;
        IRQ_OUT     : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
        INTR_Active : OUT   STD_LOGIC;
        CLR_IRQ_OUT : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);

        GIE         : IN    STD_LOGIC;
        IFG         : buffer STD_LOGIC_VECTOR(7 DOWNTO 0);
        IntrEn      : buffer STD_LOGIC_VECTOR(7 DOWNTO 0);
        FIRIFG_CLR  : OUT   STD_LOGIC
    );
END INTERRUPT;

----------------------------------------
-- Architecture Definition
----------------------------------------
ARCHITECTURE structure OF INTERRUPT IS
    SIGNAL IRQ           : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '0');
    SIGNAL CLR_IRQ       : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others => '1');
    SIGNAL TypeReg       : STD_LOGIC_VECTOR(RegSize-1 DOWNTO 0) := (others => '0');
    SIGNAL INTA_Delayed  : STD_LOGIC := '1';
    SIGNAL FIR_Type      : STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0'); -- "01"=FIFOEMPTY, "10"=FIROUT
BEGIN

    --------------------------------------------------------------------
    -- Interrupt active check
    --------------------------------------------------------------------
    INTR_Active <= IFG(0) OR IFG(1) OR IFG(2) OR IFG(3) OR IFG(4) OR IFG(5) OR IFG(6);

    --------------------------------------------------------------------
    -- FIR interrupt type decode
    --------------------------------------------------------------------
    FIR_Type <= "10" WHEN (IFG(6) = '1' AND IntrSrc(7) = '1') ELSE -- FIROUT ready
                "01" WHEN (IFG(6) = '1' AND IntrSrc(6) = '1') ELSE -- FIFOEMPTY
                "00";

    --------------------------------------------------------------------
    -- Interrupt vector type register
    --------------------------------------------------------------------
    TypeReg <= X"00" WHEN reset  = '1' ELSE
               X"10" WHEN IFG(2) = '1' ELSE -- Basic timer
               X"14" WHEN IFG(3) = '1' ELSE -- KEY1
               X"18" WHEN IFG(4) = '1' ELSE -- KEY2
               X"1C" WHEN IFG(5) = '1' ELSE -- KEY3
               X"20" WHEN (IFG(6) = '1' AND FIR_Type = "01") ELSE -- FIFOEMPTY
               X"24" WHEN (IFG(6) = '1' AND FIR_Type = "10") ELSE -- FIROUT ready
               X"00";

    --------------------------------------------------------------------
    -- IFG update process
    --------------------------------------------------------------------
    PROCESS(clock, reset)
    BEGIN
        IF (reset = '1') THEN
            IFG <= (others => '0');
        ELSIF rising_edge(clock) THEN
            IF (AddressBus = X"841" AND MemWriteBus = '1') THEN
                IFG <= DataBus(7 DOWNTO 0);
            ELSE
                IFG <= IRQ AND IntrEn;  -- normal flag update
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- IntrEn update process
    --------------------------------------------------------------------
    PROCESS(clock, reset)
    BEGIN
        IF (reset = '1') THEN
            IntrEn <= (others => '0');
        ELSIF rising_edge(clock) THEN
            IF (AddressBus = X"840" AND MemWriteBus = '1') THEN
                IntrEn <= DataBus(7 DOWNTO 0);
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- IRQ clear control
    --------------------------------------------------------------------
    CLR_IRQ(2) <= '0' WHEN (TypeReg = X"10" AND INTA = '1' AND INTA_Delayed = '0') ELSE '1';
    CLR_IRQ(3) <= '0' WHEN (TypeReg = X"14" AND INTA = '1' AND INTA_Delayed = '0') ELSE '1';
    CLR_IRQ(4) <= '0' WHEN (TypeReg = X"18" AND INTA = '1' AND INTA_Delayed = '0') ELSE '1';
    CLR_IRQ(5) <= '0' WHEN (TypeReg = X"1C" AND INTA = '1' AND INTA_Delayed = '0') ELSE '1';
    CLR_IRQ(6) <= '0' WHEN (TypeReg = X"20" AND INTA = '1' AND INTA_Delayed = '0') OR
                           (TypeReg = X"24" AND INTA = '1' AND INTA_Delayed = '0')
                  ELSE '1';

    FIRIFG_CLR <= '1' WHEN (TypeReg = X"20" AND INTA = '1' AND INTA_Delayed = '0') OR
                             (TypeReg = X"24" AND INTA = '1' AND INTA_Delayed = '0')
                  ELSE '0';

    --------------------------------------------------------------------
    -- INTR signal output
    --------------------------------------------------------------------
    PROCESS(clock)
    BEGIN
        IF rising_edge(clock) THEN
            IF (IFG /= "00000000") THEN
                INTR <= GIE;
            ELSE
                INTR <= '0';
            END IF;
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- IRQ generation processes
    --------------------------------------------------------------------
    -- Basic timer IRQ
    PROCESS(clock, reset)
    BEGIN
        IF rising_edge(clock) THEN
            IF (reset = '1') THEN
                IRQ(2) <= '0';
            ELSIF CLR_IRQ(2) = '0' THEN
                IRQ(2) <= '0';
            ELSIF IntrSrc(2) = '1' THEN
                IRQ(2) <= '1';
            END IF;
        END IF;
    END PROCESS;

    -- KEY1 IRQ
    PROCESS(clock, reset)
    BEGIN
        IF (reset = '1') THEN
            IRQ(3) <= '0';
        ELSIF CLR_IRQ(3) = '0' THEN
            IRQ(3) <= '0';
        ELSIF rising_edge(IntrSrc(3)) THEN
            IRQ(3) <= '1';
        END IF;
    END PROCESS;

    -- KEY2 IRQ
    PROCESS(clock, reset)
    BEGIN
        IF (reset = '1') THEN
            IRQ(4) <= '0';
        ELSIF CLR_IRQ(4) = '0' THEN
            IRQ(4) <= '0';
        ELSIF rising_edge(IntrSrc(4)) THEN
            IRQ(4) <= '1';
        END IF;
    END PROCESS;

    -- KEY3 IRQ
    PROCESS(clock, reset)
    BEGIN
        IF (reset = '1') THEN
            IRQ(5) <= '0';
        ELSIF CLR_IRQ(5) = '0' THEN
            IRQ(5) <= '0';
        ELSIF rising_edge(IntrSrc(5)) THEN
            IRQ(5) <= '1';
        END IF;
    END PROCESS;

    -- FIR IRQ (FIFOEMPTY/FIROUT)
    PROCESS(clock, reset)
    BEGIN
        IF (reset = '1') THEN
            IRQ(6) <= '0';
        ELSIF CLR_IRQ(6) = '0' THEN
            IRQ(6) <= '0';
        ELSIF IntrSrc(6) = '1' OR IntrSrc(7) = '1' THEN
            IRQ(6) <= '1';
        END IF;
    END PROCESS;

    --------------------------------------------------------------------
    -- DataBus read mux
    --------------------------------------------------------------------
    DataBus <= X"000000" & TypeReg  WHEN ((AddressBus = X"842" AND MemReadBus = '1')
                                          OR (INTA = '0' AND MemReadBus = '0')) ELSE
               "000000000000000000000000" & IntrEn WHEN (AddressBus = X"840" AND MemReadBus = '1') ELSE
               "000000000000000000000000" & IFG    WHEN (AddressBus = X"841" AND MemReadBus = '1') ELSE
               (OTHERS => 'Z');

    IRQ_OUT     <= IRQ;
    CLR_IRQ_OUT <= CLR_IRQ;

    --------------------------------------------------------------------
    -- INTA delay register
    --------------------------------------------------------------------
    PROCESS(clock)
    BEGIN
        IF (reset = '1') THEN
            INTA_Delayed <= '1';
        ELSIF rising_edge(clock) THEN
            INTA_Delayed <= INTA;
        END IF;
    END PROCESS;

END structure;

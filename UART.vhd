library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity UART is
  port (
    rst_n, cs, R_W, sys_clk, RxD, a1, a0: in std_logic;
    d: inout std_logic_vector  (7 downto 0);
    IRQ, TxD: out std_logic
  ) ;
end UART;

architecture Behavioral of UART is
    component UART_receiver
        port(
            RxD, Bclkx8, sys_clk, rst_n, RDRF: in std_logic;
            RDR: out std_logic_vector (7 downto 0);
            setRDRF, setOE, setFE: out std_logic
        );
    end component;

    component UART_transmitter
        port(
            Bclk, sys_clk, rst_n, TDRE, loadTDR: in std_logic;
            DBUS: in std_logic_vector (7 downto 0);
            setTDRE, TxD: out std_logic
        );
    end component;

    component UART_clkdiv
        port(
            sys_clk: in std_logic;
            sel: in std_logic_vector (2 downto 0);
            Bclkx8: buffer std_logic;
            Bclk: out std_logic
        );
    end component;

    signal RDR: std_logic_vector (7 downto 0);
    signal SCSR: std_logic_vector (7 downto 0);
    signal SCCR: std_logic_vector (7 downto 0);
    signal TDRE, RDRF, OE, FE, TIE, RIE: std_logic;
    signal Baudsel: std_logic_vector (2 downto 0);
    signal addr: std_logic_vector (1 downto 0);
    signal setTDRE, setRDRF, setOE, setFE, loadTDR, loadSCCR: std_logic;
    signal clrRDRF, Bclk, Bclkx8, SCI_Read, SCI_Write: std_logic;

    begin
        addr <= a1 & a0;
        u0: UART_receiver port map (RxD, Bclkx8, sys_clk, rst_n, RDRF, RDR, setRDRF, setOE, setFE);
        u1: UART_transmitter port map (Bclk, sys_clk, rst_n, TDRE, loadTDR, DBUS, setTDRE, TxD);
        u2: UART_clkdiv port map (sys_clk, sel, Bclkx8, Bclk);

        process (sys_clk, rst_n)
        begin
            if (rst_n = '0') then
                TDRE <= '1';
                RDRF <= '0';
                OE <= '0';
                FE <= '0';
                TIE <= '0';
                RIE <= '0';
            elsif (sys_clk'event and sys_clk = '1') then
                TDRE <= (setRDRF and (not TDRE)) or ((not loadTDR) and TDRE);
                RDRF <= (setRDRF and (not RDRF)) or ((not clrRDRF) and RDRF);
                OE <= (setOE and (not OE)) or ((not clrRDRF) and OE);
                FE <= (setFE and (not FE)) or ((not clrRDRF) and FE);
                if (loadSCCR = '1') then
                    TIE <= d(7);
                    RIE <= d(6);
                    Baudsel <=d (2 downto 0);
                end if ;
            end if;
        end process;

        IRQ <= '1' when ((RIE = '1' and (RDRF = '1' or OE = '1')) or (TIE = '1' and TDRE = '1')) else '0';
        SCSR <= TDRE & RDRF & '000' & Baudsel;
        SCI_Read <= '1' when (cs ='1' and R_W ='1') else '0';
        SCI_Write <= '1' when (cs = '1' and R_W = '0') else '0';
        clrRDRF <= '1' when (SCI_Read = '1' and addr = '00') else '0';
        loadTDR <= '1' when (SCI_Write = '1' and addr = '00') else '0';
        loadSCCR <= '1' when (SCI_Write = '1' and addr = '10') else '0';
        d <= 'zzzzzzzz' when (SCI_Read = '0') else
        RDR when (addr = '00') else
        SCSR when (addr = '01') else
        SCCR;
end Behavioral;

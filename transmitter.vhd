--数据发送器
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity UART_transmitter is
    port(
        Bclk:    in std_logic;
        sys_clk: in std_logic;
        rst_n:   in std_logic;
        TDRE:    in std_logic;
        loadTDR: in std_logic;
        setTDRE: out std_logic;
        TxD:     out std_logic;
        DBUS:    in std_logic_vector(7 downto 0)
    );
end UART_transmitter;

architecture Behavioral of UART_transmitter is
    type state_type is (T_wait, synch, T_data);
    signal state, nextstate: state_type;
    signal TDR: std_logic_vector(7 downto 0);
    signal TSR: std_logic_vector(8 downto 0);
    signal Bcnt: integer range 0 to 9;
    signal inc, clr, loadTSR, shiftTSR, start: std_logic;
    signal Bclk_rising, Bclk_Delayed: std_logic;
begin
    TxD <= TSR(0);
    setTDRE <=loadTSR;
    Bclk_rising <= Bclk and (not Bclk_Delayed);

--T_control
    process (state, TDRE, Bcnt, Bclk_rising)
    begin
        inc <= '0';
        clr <= '0';
        loadTSR <= '0';
        shiftTSR <= '0';
        start <= '0';
        case state is
            when T_wait =>
            if (TDRE = '0') then
                loadTSR <= '1';
                nextstate <= synch;
            else
                netxstate <= T_wait;
            end if;
            when synch =>
            if (Bclk_rising = '1') then
                start <= '1';
                nextstate <= T_data;
            else
                nextstate <= synch;
            end if;
            when T_data =>
            if (Bclk_rising = '0') then
                nextstate <= T_data;
            elsif (Bcnt /= 9) then
                shiftTSR <= '1';
                nextstate <= T_data;
            else
                clr <= '1';
                nextstate <= T_wait;
            end if;
        end case;
    end process;

    --T_updale
    process(sys_clk, rst_n)
    begin
        if (rst_n = '0') then
            TSR <= '111111111';
            state <= T_wait;
            Bcnt <= 0;
            Bclk_Delayed <= '0';
        elsif (sys_clk'event and sys_clk = '1') then
            state <= nextstate;
            if (clr = '1') then
                Bcnt <= 0;
            elsif (inc = '1') then
                Bcnt <= Bcnt + 1;
            end if;

            if (loadTDR = '1') then
                TDR <= DBUS;
            end if;

            if (loadTSR = '1') then
                TSR <= TDR & '1';
            elsif (start = '1') then
                TSR(0) <= '0';
            elsif (shiftTSR) then
                TSR <= '1' & TSR (8 downto 1);
            end if;

            Bclk_Delayed <= Bclk;
        end if;
    end process;
end Behavioral;
            
            

        
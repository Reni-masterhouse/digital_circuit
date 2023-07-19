--数据发送
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity UART_transmitter is
    port(
        sys_clk: in std_logic;
        rst_n:   in std_logic;
        start:   in std_logic;
        data:    in std_logic_vector(7 downto 0);
        rs232:   out std_logic;
        done:    out std_logic
    );
end UART_transmitter;

architecture Behavioral of UART_transmitter is
    signal state: std_logic;
    signal r_data: std_logic_vector(7 downto 0);
    signal baud_cnt: std_logic_vector(12 downto 0);
    signal bit_cnt: std_logic_vector(3 downto 0);
    signal bit_flag: std_logic;
--   signal Bclk_rising, Bclk_Delayed: std_logic;

begin
    process (sys_clk, rst_n)
    begin
        if rst_n = '0' then
            r_data <= "00000000";
        elsif rising_edge(sys_clk) then
            if start = '0' then
                r_data <= data;
           else 
                r_data <= r_data;
            end if;
        end if;
    end process;

    process (sys_clk, rst_n)
    begin
        if rst_n = '0' then
            state <= 1'b0;
        elsif rising_edge(sys_clk) then
            if start = '0' then
                r_data <= data;
           else 
                r_data <= r_data;
            end if;
        end if;
    end process;
end Behavioral;

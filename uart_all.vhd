library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use ieee.std_logic_arith.all;
-- use ieee.std_logic_unsigned.all;
-- use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity uart_all is
    port(
        clk: in std_logic;
        rst: in std_logic;
        rs232_in: in std_logic;
        rs232_out: out std_logic
    );
end uart_all;

architecture Behavioral of uart_all is
    component uart_rx
        port(
            clk: in std_logic;
            rst: in std_logic;
            rs232: in std_logic;

            rx_data: out std_logic_vector(7 downto 0);
            done: out std_logic
        );
    end component;

    component uart_tx
        port(
            clk: in std_logic;
            rst: in std_logic;
            start: in std_logic;
            data: in std_logic_vector(7 downto 0);

            rs232: out std_logic;
            done: out std_logic
        );
    end component;

    signal rx_data: std_logic_vector(7 downto 0);
    signal read_done: std_logic;
    signal write_done: std_logic;
    
    signal write_start: std_logic;
    signal tx_data: std_logic_vector(7 downto 0);
    -- signal tx_int: integer;
begin
    uart_rx_ins: uart_rx port map (clk=>clk, rst=>rst, rs232=>rs232_in, rx_data=>rx_data, done=>read_done);
    uart_tx_ins: uart_tx port map (clk=>clk, rst=>rst, start=>write_start, data=>tx_data, rs232=>rs232_out, done=>write_done);

    process(clk, rst)
    variable tx_int: integer;
    begin
        if rst = '0' then
            write_start <= '0';
            tx_data <= "00000000";
        elsif rising_edge(clk) then
            if read_done = '1' then
                -- tx_data <= rx_data;
                tx_int := to_integer(unsigned(rx_data));
                if tx_int >= 97 and tx_int <= 122 then
                    tx_data <= std_logic_vector(to_unsigned(tx_int - 32, 8));
                elsif tx_int >= 65 and tx_int <= 90 then
                    tx_data <= std_logic_vector(to_unsigned(tx_int + 32, 8));
                else
                    tx_data <= "01000000";
                end if;
                -- tx_data <= "01000000";
                write_start <= '1';
            elsif write_start = '1' then
                write_start <= '0';
            end if;
        end if;
    end process;
end Behavioral;

        
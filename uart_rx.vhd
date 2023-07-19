library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart_rx is
    port(
        clk: in std_logic;
        rst: in std_logic;
        rs232: in std_logic;

        rx_data: out std_logic_vector(7 downto 0);
        done: out std_logic
    );
end uart_rx;

architecture Behavioral of uart_rx is
    signal rs232_t: std_logic; 
    signal rs232_t1: std_logic; 
    signal rs232_t2: std_logic; 
    signal state: std_logic;

    signal baud_cnt :integer range 0 to 6000;
    signal bit_flag: std_logic;
    signal bit_cnt: integer range 0 to 15;

    signal nege: std_logic;
    signal done_tmp: std_logic;
begin
    done <= done_tmp;
    process (clk, rst)
    begin
        if rst = '0' then
            rs232_t <= '1';
            rs232_t1 <= '1';
            rs232_t2 <= '1';
        elsif rising_edge(clk) then
            rs232_t <= rs232;
            rs232_t1 <= rs232_t;
            rs232_t2 <= rs232_t1;
        end if;
    end process;

    nege <= rs232_t2 and not rs232_t1;

    --------- state -----------
    process (clk, rst)
    begin
        if rst = '0' then
            state <= '0';
        elsif rising_edge(clk) then
            if nege = '1' then
                state <= '1';
            elsif done_tmp = '1' then
                state <= '0';
            else
                state <= state;
            end if;
        end if;
    end process;

    --------------- baud_cnt -----------------
    process (clk, rst)
    begin
        if rst = '0' then
            baud_cnt <= 0;
        elsif rising_edge(clk) then
            if state = '1' then
                if baud_cnt = 5207 then --5207
                    baud_cnt <= 0;
                else
                    baud_cnt <= baud_cnt + 1;
                end if;
            else
                baud_cnt <= 0;
            end if;
        end if;
    end process;

    ------------- bit_flag ---------------
    process (clk, rst)
    begin
        if rst = '0' then
            bit_flag <= '0';
        elsif rising_edge(clk) then
            if baud_cnt = 2604 then --2604
                bit_flag <= '1';
            else
                bit_flag <= '0';
            end if;
        end if;
    end process;

    ------------- bit_cnt ---------------
    process (clk, rst)
    begin
        if rst = '0' then
            bit_cnt <= 0;
        elsif rising_edge(clk) then
            if bit_flag = '1' then
                if bit_cnt = 10 then
                    bit_cnt <= 0;
                else
                    bit_cnt <= bit_cnt + 1;
                end if;
            else
                bit_cnt <= bit_cnt;
            end if;
        end if;
    end process;

    ------------- rx_data ---------------
    process (clk, rst)
    begin
        if rst = '0' then
            rx_data <= "00000000";
        elsif rising_edge(clk) then
            if state = '1' then
                if bit_flag = '1' then
                    case bit_cnt is
                        when 1 => rx_data(0) <= rs232_t2;
                        when 2 => rx_data(1) <= rs232_t2;
                        when 3 => rx_data(2) <= rs232_t2;
                        when 4 => rx_data(3) <= rs232_t2;
                        when 5 => rx_data(4) <= rs232_t2;
                        when 6 => rx_data(5) <= rs232_t2;
                        when 7 => rx_data(6) <= rs232_t2;
                        when 8 => rx_data(7) <= rs232_t2;
                        when others => null;
                    end case;
                end if;
            else
                rx_data <= "00000000";
            end if;
        end if;
    end process;
    
    ----------- done ------------
    process (clk, rst)
    begin
        if rst = '0' then
            done_tmp <= '0';
        elsif rising_edge(clk) then
            if bit_flag = '1' and bit_cnt = 10 then
                done_tmp <= '1';
            else
                done_tmp <= '0';
            end if;
        end if;
    end process;
end Behavioral;
            
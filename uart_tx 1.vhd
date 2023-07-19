library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart_tx is
    port(
        clk: in std_logic;
        rst: in std_logic;
        start: in std_logic;
        data: in std_logic_vector(7 downto 0);

        rs232: out std_logic;
        done: out std_logic
    );
end uart_tx;

architecture Behavioral of uart_tx is
    signal r_data: std_logic_vector(7 downto 0) := "00000000";
    signal state: std_logic = '0';
    signal baud_cnt :integer range 0 to 6000 := 0;
    signal bit_flag: std_logic := '0';
    signal bit_cnt: integer range 0 to 15 := 0;
    signal done_tmp: std_logic := '0';
begin
    done <= done_tmp;
    --------------- r_data -----------------
    process (clk, rst)
    begin
        if rst = '0' then
            r_data <= "00000000";
        elsif rising_edge(clk) then
            if start = '1' then
                r_data <= data;
            else
                r_data <= r_data;
            end if;
        end if;
    end process;
    --------------- state -----------------

    process (clk, rst)
    begin
        if rst = '0' then
            state <= '0';
        elsif rising_edge(clk) then
            if start = '1' then
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
            if baud_cnt = 1 then
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

    ------------- rs232 ---------------
    process (clk, rst)
    begin
        if rst = '0' then
            rs232 <= '1';
        elsif rising_edge(clk) then
            if state = '1' then
                if bit_flag = '1' then
                    case bit_cnt is
                        when 0 => rs232 <= '0';
                        when 1 => rs232 <= r_data(0);
                        when 2 => rs232 <= r_data(1);
                        when 3 => rs232 <= r_data(2);
                        when 4 => rs232 <= r_data(3);
                        when 5 => rs232 <= r_data(4);
                        when 6 => rs232 <= r_data(5);
                        when 7 => rs232 <= r_data(6);
                        when 8 => rs232 <= r_data(7);
                        when 9 => rs232 <= '1';
                        when others => rs232 <= '1';
                    end case;
                end if;
            else
                rs232 <= '1';
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
            
            

        
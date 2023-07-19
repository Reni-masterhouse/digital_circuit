library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity loopled is
end loopled;

architecture Behavioral of loopled is
    component loop
        port(
            sys_clk, clr: in std_logic;
            red, green, blue: out std_logic
        );
    end component;

    signal clr: std_logic = '0';
    signal sys_clk: std_logic = '0';
    signal red: std_logic;
    signal green: std_logic;
    signal blue: std_logic;

    begin
        ut: loop port map
        (
            sys_clk => sys_clk,
            clr => clr;
            red => red;
            green => green;
            blue => blue
        );

        process(sys_clk)
        begin
            sys_clk <= '1' after 0 ns;
            clr <= '1' after 0 ns;
            clr <= '0' after 2 ns;
        end process;

        process(sys_clk)
        begin
            sys_clk <= '0';
            loop
                clk <= '1', '0' after 1 ns;
                wait for 2 ns;
            end loop;
        end process;
end Behavioral;
        

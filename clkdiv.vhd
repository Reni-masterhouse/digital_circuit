library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity UART_clkdiv is
    port(
        sys_clk: in std_logic;
        sel: in std_logic_vector (2 downto 0);
        Bclkx8: buffer std_logic;
        Bclk: out std_logic
    );
end UART_clkdiv;

architecture Behavioral of UART_clkdiv is
    signal div1: std_logic_vector (3 downto 0):= '0000';
    signal div2: std_logic_vector (7 downto 0):= '00000000';
    signal div3: std_logic_vector (2 downto 0):= '000';
    signal clkdivl3: std_logic;
begin

--div13
    process(sys_clk)
    begin
        if (sys_clk'event and sys_clk = '1') then 
            if (div1 = '1100') then 
                div1 <= '0000';
            else
                div1 <= div1 + 1;
            end if;
        end if;
    end process;

    clkdivl3 <= div1(3);

--clkdiv13
    process(clkdivl3)
    begin
        if (clkdivl3'event and clkdivl3 ='1') then
            div2 <= div2 + 1;
        end if;
    end process;

    Bclkx8 <= div2 (conv_integer(sel));

    process(Bclkx8)
    begin
        if (Bclkx8'event and Bclkx8 = '1') then
            div3 <= div3 + 1;
        end if;
    end process;

    Bclk <= div3(2);

end Behavioral;




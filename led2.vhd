library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity led is
    port(
        sys_clk :in std_logic;
        rst_n   :in std_logic;
        led     :out std_logic_vector(3 downto 0)
    );
end led;

architecture Behavioral of led is
    signal timer_cnt : integer := 0;
    signal led_tmp : std_logic_vector(3 downto 0) := "0000" ;
    constant dt : integer := 50000000;
begin
    process (sys_clk, rst_n)
    begin
        if rising_edge(sys_clk) then
			if rst_n = '0' then
				led_tmp <= "0000";
				timer_cnt <= 0;
			else
				if timer_cnt < dt then
					led_tmp <= "1000";
				elsif timer_cnt < 2 * dt then
					led_tmp <= "0100";
				elsif timer_cnt < 3 * dt then
					led_tmp <= "0010";
				elsif timer_cnt < 4 * dt then
					led_tmp <= "0001";
				else
					timer_cnt <= 0;
				end if;
				timer_cnt <= timer_cnt + 1;
			end if;
		end if;
    end process;
    led <= led_tmp;

end Behavioral;
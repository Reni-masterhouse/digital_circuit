library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity counter8 is
    port (
        sys_clk  :in std_logic;
        button_a :in std_logic;
        button_b :in std_logic;
        button_c :in std_logic;
        button_d :in std_logic;
        led :out std_logic_vector(3 downto 0)
    );
end counter8;

architecture Behavioral of counter8 is
    signal timer_cnt : integer := 0;
    signal sum : integer := 0;
    signal state : std_logic := '0';
    signal led8 : std_logic_vector(7 downto 0);
    signal onesecond : std_logic := '0';
begin
    process (button_a)
    begin
        if rising_edge(button_a) then
            sum <= sum + 1;
        end if;    
    end process;

    process (button_b)
    begin
        if rising_edge(button_b) then
            sum <= sum - 1;
        end if;
    end process;

    led8 <= conv_std_logic_vector(sum, 8);

    process(sys_clk)
    begin
        if rising_edge(sys_clk) then
            if button_c = '0' then
                timer_cnt <= timer_cnt + 1;
                if timer_cnt = 50000000 then 
                    onesecond <= '1';
                end if;
            else
                timer_cnt <= 0;
            end if;
        end if;
    end process;

    process(button_c)
    begin
        if rising_edge(button_c) then
            if onesecond = '1' then 
                sum <= 0;
                onesecond <= '0';
                timer_cnt <= 0;
            else
                state <= not state;
            end if;
        end if;
    end process;

    process(state)
    begin
        if state = '0' then
            led <= led8(3 downto 0);
        elsif
            led <= led8(7 downto 4);
        end if;
    end process;

    process(button_d)
    begin
        if rising_edge(button_d) then
            sum <= 0;
            state <= '0';
        end if;
    end process;    

end Behavioral;
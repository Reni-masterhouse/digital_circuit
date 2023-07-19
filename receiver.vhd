--数据接收器
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity UART_receiver is
    port(
        sys_clk :in std_logic;  --系统时钟
        rst_n   :in std_logic;  --reset
        RxD     :in std_logic;  --电表接收信号灯
	    Bclkx8. :in std_logic;  --clock
	    RDRF    :in std_logic;  --接收数据寄存器
	    setRDRF :out std_logic; 
	    setOE   :out std_logic;
	    setFE   :out std_logic;
	    RDR     :out std_logic_vector(7 downto 0)
    );
end UART_receiver;

architecture Behavioral of UART_receiver is
    type state_type is(R_wait, start_detected, R_data);
    signal RSR: std_logic_vector(7 downto 0);
    signal cnt1: integer range 0 to 7;
    signal cnt2: integer range 0 to 8;
    signal clr1, clr2: std_logic;
    signal inc1, inc2, shiftRSR: std_logic;
    signal Bclkx8_Delayed, Bclkx8_rising: std_logic;
begin
Bclkx8_rising <= Bclkx8 and (not Bclkx8_Delayed); --触发器

--控制器 R_control
    process(state, RxD, RDRF, cnt1, cnt2, Bclkx8_rising)
    begin
        shiftRSR <= '0';
        loadRDR <= '0';
        setRDRF <= '0';
        setOE <= '0';
        setFE <= '0';
        case state is                                   --条件选择
            when R_wait =>
                if (RxD = '0') then
                    nextstate <= start_detected;
                else
                    nextstate <= R_wait;
                end if;
            when start_detected =>
                if(Bclkx8_rising = '0') then
                    nextstate <= start_detected;
                elsif(RxD = '1') then
                    clr1 <= '1';
                    nextstate <= R_wait;
                elsif(cnt1 = 3) then
                    clr1 <= '1';
                    nextstate <= R_wait;
                else
                    inc1 <= '1';
                    nextstate <= start_detected;
                end if;
            when R_data =>
                if (Bclkx8_rising = '0') then
                    nextstate <= R_data;
                else
                    inc1 <= '1';
                    if (cnt1 /= 7) then
                        nextstate <= R_data;
                    elsif (cnt2 /= 8) then
                        shiftRSR <= '1';
                        inc2 <= '1';
                        clr1 <= '1';
                        nextstate <= R_data;
                    else
                        nextstate <= R_wait;
                        setRDRF <= '1';
                        clr1 <= '1';
                        clr2 <= '1';
                        if (RDRF = '1') then
                            setOE <= '1';
                        elsif (RxD = '0') then 
                            setFE <= '1';
                        else 
                            loadRDR <= '1';
                        end if;
                    end if;
                end if;
        end case;
    end process;

--R_updale
    process (sys_clk, rst_n)
    begin
        if (reset = '0') then
            state <= R_wait;
            Bclkx8_Delayed <= '0';
            cnt1 <= 0;
            cnt2 <= 0;
        elsif (sys_clk'event and sys_clk = '1') then
            state <= nextstate;
            if (clr1 = '1') then
                cnt1 <= 0;
            elsif (inc1 = '1') then
                cnt1 <= cnt1 + 1;
            end if;
            
            if (clr2 = '1') then 
                cnt2 <= 0;
            elsif (inc2 = '1') then
                cnt2 <= cnt2 + 1;
            end if;
            
            if (shiftRSR = '1') then
                RSR <= RxD & RSR (7 downto 1);
            end if;
            
            if (loadRDR = '1') then
                RDR <= RSR;
            end if;
            
            Bclkx8_Delayed <= Bclkx8;
        end if;
    end process;
end architecture;
        
        


                


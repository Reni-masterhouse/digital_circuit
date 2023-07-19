library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

entity uart_buf_send is
    port(
        clk: in std_logic;
        -- rst: in std_logic;
        btn_a: in std_logic;
        btn_b: in std_logic;
        btn_c: in std_logic;
        btn_d: in std_logic;
        rs232: out std_logic
    );
end uart_buf_send;

architecture Behavioral of uart_buf_send is

component uart_tx is
    port(
        clk: in std_logic;
        rst: in std_logic;
        start: in std_logic;
        data: in std_logic_vector(7 downto 0);

        rs232: out std_logic;
        done: out std_logic
    );
end component;

--component debouncer is
--  generic(
--    clk_freq    : integer := 50_000_000;  -- 50MHz
--    stable_time : integer := 20);         -- 20ms
--  port( 
--    clk: in std_logic;
--    rst: in std_logic;
--    btn: in std_logic;
--    btn_out: out std_logic
--  );
--end component;

-- read
signal write_done: std_logic;

-- write
signal write_start: std_logic := '0';
signal tx_data: std_logic_vector(7 downto 0) := "00000000";

signal cur_idx : integer := 0;

type bufstate is (IDLE, SENDA, WAITA, SENDB, WAITB, SENDC, WAITC, SENDD, WAITD);
signal state: bufstate := IDLE;

constant data_a: std_logic_vector(55 downto 0) := X"47_46_45_44_43_42_41"; -- ABCDEFG
constant data_b: std_logic_vector(55 downto 0) := X"67_66_65_64_63_62_61"; -- abcdefg
constant data_c: std_logic_vector(55 downto 0) := X"37_36_35_34_33_32_31"; -- 1234567
constant data_d: std_logic_vector(79 downto 0) := X"29_28_2A_26_5E_25_24_23_22_21"; -- 

constant bytes_a: integer := 7;
constant bytes_b: integer := 7;
constant bytes_c: integer := 7;
constant bytes_d: integer := 10;

signal rst: std_logic := '1'

signal stable_a: std_logic;
signal last_a: std_logic := '1';
signal pos_a: std_logic := '0';

signal stable_b: std_logic;
signal last_b: std_logic := '1';
signal pos_b: std_logic := '0';

signal stable_c: std_logic;
signal last_c: std_logic := '1';
signal pos_c: std_logic := '0';

signal stable_d: std_logic;
signal last_d: std_logic := '1';
signal pos_d: std_logic := '0';

begin
    uart_tx_ins: uart_tx port map (clk=>clk, rst=>rst, start=>write_start, data=>tx_data, rs232=>rs232, done=>write_done);
    -- debouncer_a: debouncer port map (clk=>clk, rst=>rst,btn=>btn_a,btn_out=>stable_a);
    pos_a <= stable_a and not last_a;
    pos_b <= stable_b and not last_b;
    pos_c <= stable_c and not last_c;
    pos_d <= stable_d and not last_d;
    stable_a <= btn_a;
    stable_b <= btn_b;
    stable_c <= btn_c;
    stable_d <= btn_d;

    process(clk, rst) 
    begin
        if rst = '0' then
            write_start <= '0';
            tx_data <= "00000000";
            cur_idx <= 0;
            state <= IDLE;
            last_a <= '1';
            last_b <= '1';
            last_c <= '1';
            last_d <= '1';
        elsif rising_edge(clk) then
            last_a <= stable_a;
            last_b <= stable_b;
            last_c <= stable_c;
            last_d <= stable_d;
            case state is 
                when IDLE =>
                    if pos_a = '1' then
                        cur_idx <= 0;
                        state <= SENDA;
                    elsif pos_b = '1' then
                        cur_idx <= 0;
                        state <= SENDB;
                    elsif pos_c = '1' then
                        cur_idx <= 0;
                        state <= SENDC;
                    elsif pos_d = '1' then
                        cur_idx <= 0;
                        state <= SENDD;
                    end if;
                when SENDA => 
                    tx_data <= data_a(cur_idx*8 + 7 downto cur_idx * 8);
                    write_start <= '1';
                    state <= WAITA;
                when WAITA => 
                    if write_start = '1' then
                        write_start <= '0';
                    end if;
                    if write_done = '1' then
                        if cur_idx + 1 = bytes_a then
                            state <= IDLE; 
                            cur_idx <= 0;
                            tx_data <= "00000000";
                        else
                            cur_idx <= cur_idx + 1;
                            state <= SENDA;
                        end if;
                    end if;

                when SENDB => 
                    tx_data <= data_b(cur_idx*8 + 7 downto cur_idx * 8);
                    write_start <= '1';
                    state <= WAITB;
                when WAITB => 
                    if write_start = '1' then
                        write_start <= '0';
                    end if;
                    if write_done = '1' then
                        if cur_idx + 1 = bytes_b then
                            state <= IDLE; 
                            cur_idx <= 0;
                            tx_data <= "00000000";
                        else
                            cur_idx <= cur_idx + 1;
                            state <= SENDB;
                        end if;
                    end if;

                when SENDC => 
                    tx_data <= data_c(cur_idx*8 + 7 downto cur_idx * 8);
                    write_start <= '1';
                    state <= WAITC;
                when WAITC => 
                    if write_start = '1' then
                        write_start <= '0';
                    end if;
                    if write_done = '1' then
                        if cur_idx + 1 = bytes_c then
                            state <= IDLE; 
                            cur_idx <= 0;
                            tx_data <= "00000000";
                        else
                            cur_idx <= cur_idx + 1;
                            state <= SENDC;
                        end if;
                    end if;

                when SENDD => 
                    tx_data <= data_d(cur_idx*8 + 7 downto cur_idx * 8);
                    write_start <= '1';
                    state <= WAITD;
                when WAITD => 
                    if write_start = '1' then
                        write_start <= '0';
                    end if;
                    if write_done = '1' then
                        if cur_idx + 1 = bytes_d then
                            state <= IDLE; 
                            cur_idx <= 1;
                            tx_data <= "00000000";
                        else
                            cur_idx <= cur_idx + 1;
                            state <= SENDD;
                        end if;
                    end if;
            end case;
        end if;
    end process;

end Behavioral;
            
            

        
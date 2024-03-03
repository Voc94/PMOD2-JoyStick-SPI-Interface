----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/15/2023 07:37:42 PM
-- Design Name: 
-- Module Name: SPI_Master - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SPI_Master is
    Port ( 
           reset : in STD_LOGIC;
           enable : in STD_LOGIC;
           sclk : out STD_LOGIC;
           ss_n : out STD_LOGIC;
           clk : in STD_LOGIC;
           ce_n : out STD_LOGIC;
           ce_p : out STD_LOGIC;
           miso : in STD_LOGIC;
           mosi : out STD_LOGIC := '0';
           busy : out STD_LOGIC;
           tx_data : in std_logic_vector(7 downto 0);
           rx_data : out std_logic_vector(7 downto 0);
           curr_state_signal : out STD_LOGIC  
           );
end SPI_Master;

architecture Behavioral of SPI_Master is
component left_shift_reg is
    Port ( Sin : in STD_LOGIC;
           Sout : out STD_LOGIC:= '0';
           D : in STD_LOGIC_VECTOR (7 downto 0);
           Q : out STD_LOGIC_VECTOR (7 downto 0);
           clk : in STD_LOGIC;
           load : in STD_LOGIC;
           left_shift : in STD_LOGIC);
end component;
component SCLK_Gen is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        enable : in STD_LOGIC; -- Add enable
        sclk : out STD_LOGIC;
        CE_p : out STD_LOGIC;
        CE_n : out STD_LOGIC
    );
end component;
    -- SPI MASTER
    type machine is (ready, execute);
    signal curr_state, next_state : machine := ready;  -- Initialize the current state
    signal Sin_temp : std_logic;
    signal sclk_signal : std_logic := '1';
    signal LdTxRx, ShTxRx : std_logic;
    signal counter : integer range 0 to 8 := 0;
    signal busy_internal : std_logic := '0';  -- Separate internal signal for busy
    signal enable_signal : std_logic := '0';
    -- SCLK_GEN
    constant SYS_CLK_FREQUENCY : INTEGER := 100_000_000;  -- system clock frequency (100 MHz)
    constant SCLK_TARGET_FREQUENCY : INTEGER := 1_000_000; -- SCLK frequency (4 MHz)
    signal counter_sclk : INTEGER := 0;
    signal clock_period : INTEGER := integer(SYS_CLK_FREQUENCY / (SCLK_TARGET_FREQUENCY));
    signal CE_p_internal : STD_LOGIC := '0';
    signal CE_n_internal : STD_LOGIC := '0';
    signal sclk_internal : STD_LOGIC := '0';

    -- LEFT SHIFT REG
    signal value_stored : std_logic_vector(7 downto 0) := "00000000";
    signal Sin : std_logic := '0';
    signal reset_signal,reset_clk : std_logic := '0';
    signal rx_data_signal : std_logic_vector(7 downto 0) := "00000000";
begin
--SPI MASTER STATE LOGIC
--   STATE_LOGIC: process(sclk_signal, reset)
--    begin
--        if reset = '1' then
--            busy_internal <= '1';
--            ss_n <= '1';
--        elsif rising_edge(sclk_signal) then
--            curr_state <= next_state;

--            case curr_state is
--                when ready =>
--                    counter <= 0;
--                    busy_internal <= '0';
--                    ss_n <= '1';
--                    LdTxRx <= '1';
--                   -- mosi <= 'Z';
--                    if enable = '1' then
--                        busy_internal <= '1';
--                        ss_n <= '0';
--                        curr_state<=next_state;
--                    end if;
--                when execute =>
--                    if counter = 0 then
                        
--                        -- Start shifting during the execute state
--                        ss_n <= '0';
--                        LdTxRx <= '0';
--                        ShTxRx <= '1';
--                    end if;

--                    if counter < 8 then
--                        -- Continue shifting during the execute state
--                        counter <= counter + 1;
--                    else
--                        -- After shifting 8 bits, reset shift signal and transition back to ready state
--                        ShTxRx <= '0';
--                        counter <= 0;
--                        ss_n <= '1';
--                        busy_internal <= '0';  -- Clear busy signal
--                        curr_state <= next_state;
--                    end if;
--            end case;
--        end if;
--    end process;
    
--    NEXT_STATE_LOGIC : process(clk,reset)
--    begin
--    if reset = '1' then
--        next_state <= ready;
--    elsif rising_edge(clk) then
--        case curr_state is
--        when ready =>
--           if enable = '1' then
--              next_state <= execute;
--            end if;
--        when execute =>
--            if counter > 7 then
--             next_state <= ready;
--            end if;
--        end case;
--    end if;
--    end process;
    STATE_LOGIC : process(clk, reset,enable)
    begin
        if reset = '1' or enable = '0' then
            counter <= 0;
            LdTxRx <= '1';
            reset_signal <= '1';
            next_state <= ready;
        elsif rising_edge(clk) then
            curr_state <= next_state;

            case curr_state is
                when ready =>
                    busy_internal <= '0';
                    ShTxRx <= '0';
                    LdTxRx <= '1';
                    if enable = '1' and rx_data_signal = "00000000" and counter = 0 then
                        enable_signal <= '1';
                        next_state <= execute;
                    end if;

                when execute =>
                    busy_internal <= '1';
                    ShTxRx <= '1';
                    LdTxRx <= '0';
                    if ce_p_internal = '1' and counter < 7 then
                        counter <= counter + 1;
                    elsif ce_n_internal = '1' and counter = 7 then
                        counter <= 0;
                        ShTxRx <= '0';
                    elsif enable = '0' then
                        next_state <= ready;
                    end if;
            end case;
        end if;
    end process;
    
    process(ce_p_internal)
    begin
        if rising_edge(ce_p_internal) then
            Sin <= miso;
        end if;
    end process;
    ss_n <= not busy_internal;
    curr_state_signal <= '0' when curr_state = ready else '1';
    busy <= busy_internal;
    sclk <= sclk_signal;
    ce_p <= CE_p_internal;
    ce_n <= CE_n_internal;
    --SCLK
    clock_gen: SCLK_Gen port map (
        enable => enable,
        clk => clk,           -- System clock
        reset => reset,       -- Reset signal
        sclk => sclk_signal,         -- Directly connect to sclk of SPI_Master
        CE_p => CE_p_internal,         -- Directly connect to ce_p of SPI_Master
        CE_n => CE_n_internal          -- Directly connect to ce_n of SPI_Master
    );
    --LEFT SHIFT
    reset_clk <= ce_n_internal or reset;
       left_shift_component: left_shift_reg port map (
               Sin => Sin,
               Sout => mosi,
               D => tx_data,
               Q => rx_data_signal,
               clk => reset_clk,
               load => LdTxRx,
               left_shift => ShTxRx
           );
         rx_data<= rx_data_signal;
end Behavioral;

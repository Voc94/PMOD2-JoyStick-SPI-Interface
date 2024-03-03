----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/15/2023 07:37:42 PM
-- Design Name: 
-- Module Name: FSM - Behavioral
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
use IEEE.NUMERIC_STD.ALL;  -- Include numeric_std for to_integer function

entity FSM is
    Port ( start : in STD_LOGIC;
           reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           sclk : out STD_LOGIC;
           miso : in STD_LOGIC;
           mosi : out STD_LOGIC;
           x : out STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
           y : out STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
           ss_n : out STD_LOGIC);
end FSM;

architecture Behavioral of FSM is
    component SPI_Master is
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
           rx_data : out std_logic_vector(7 downto 0)
           );
end component;
    type state_machine is (init, byte_trans, byte_pause, output_res);
    signal curr_state : state_machine := init;
    signal next_state : state_machine := init;
    signal byte_counter : integer := 4;
    signal x_out,y_out : std_logic_vector(15 downto 0);
    signal byte_recieved : std_logic_vector(7 downto 0);
    signal enable,output : std_logic;
    signal busy_signal,ss_n_signal,sclk_signal,reset_signal : std_logic;
    -- Additional signals for timing
          signal counter : integer := 0;
        constant STARTUP_TIME : Integer := 10_000_000;
--        constant STARTUP_TIME : Integer := 1_000;
        constant BYTE_TIME : Integer := 1_500;
        constant PAUSE_TIME : INTEGER := 100;
begin
     SPI_Instance: SPI_Master
       port map (
           reset => reset_signal,
           enable => enable,
           sclk => sclk_signal,
           ss_n => ss_n_signal,
           clk => clk,
           miso => miso,
           mosi => mosi,
           busy => busy_signal,
           tx_data => "00000000",
           rx_data => byte_recieved
       );
       sclk <= sclk_signal;
       ss_n <= ss_n_signal or output;
--               process(clk, reset)
--      begin
--          if reset = '1' then
--              -- Reset all relevant signals
--              counter <= 0;
--              enable <= '0';
--              curr_state <= init;
--              byte_counter <= 4;
--              x_out <= (others => '0');
--              y_out <= (others => '0');
--          elsif rising_edge(clk) then
--              if start = '1' then
--                  curr_state <= next_state;
              
--                  case curr_state is
--                      when init =>
--                          if counter >= STARTUP_TIME then
--                              counter <= 0;
--                              next_state <= byte_trans;
--                          else
--                              counter <= counter + 1;
--                          end if;
        process(clk, reset,start)
      begin
          if reset = '1' then
              -- Reset all relevant signals
                reset_signal <= '1';
                counter <= 0;
                enable <= '0';
                output <= '0';
                curr_state <= init;
                byte_counter <= 4;
                x_out <= (others => '0');
                y_out <= (others => '0');
          elsif rising_edge(clk) and start = '1' then
              curr_state <= next_state;
          
              case curr_state is
              when init =>
                if counter >= STARTUP_TIME then
                        counter <= 0;
                    next_state <= byte_trans;
                else
                    counter <= counter + 1;
                end if;
              when byte_trans =>
                   if counter > BYTE_TIME then
                        counter <= 0;
                            case byte_counter is
                            when 4 => x_out(15 downto 8) <= byte_recieved;
                            when 3 => x_out(7 downto 0) <= byte_recieved;
                            when 2 => y_out(15 downto 8) <= byte_recieved;
                            when 1 => y_out(7 downto 0) <= byte_recieved;
                            when others => next_state <= init;
                        end case;         
                        reset_signal <= '1';
                        next_state <= byte_pause;
                   else
                    reset_signal <= '0';
                    enable <= '1';
                    counter <= counter + 1;
                 end if;
                 when byte_pause =>
                     enable <= '0';
                     if counter > PAUSE_TIME then      
                        counter <= 0;
                        byte_counter <= byte_counter - 1;
                         if byte_counter = 1 then 
                            next_state <= output_res;
                         else
                            next_state <= byte_trans;
                         end if;
                     else
                        counter <= counter + 1;
                     end if;
                 when output_res =>
                    output <= '1';
                    x <= x_out;
                    y <= y_out;
                  
              end case;
          end if;
      end process;

end Behavioral;
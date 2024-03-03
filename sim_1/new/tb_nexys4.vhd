-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : 9.1.2024 18:18:54 UTC

library ieee;
use ieee.std_logic_1164.all;

entity tb_nexys4 is
end tb_nexys4;

architecture tb of tb_nexys4 is

    component nexys4
        port (clk       : in std_logic;
              start     : in std_logic;
              rst       : in std_logic;
              miso      : in std_logic;
              ss        : out std_logic;
              sclk      : out std_logic;
              mosi      : out std_logic;
              color_led : out std_logic_vector (2 downto 0);
              data      : out std_logic_vector (31 downto 0);
              an        : out std_logic_vector (7 downto 0);
              cat       : out std_logic_vector (6 downto 0));
    end component;

    signal clk       : std_logic;
    signal start     : std_logic;
    signal rst       : std_logic;
    signal miso      : std_logic;
    signal ss        : std_logic;
    signal sclk      : std_logic;
    signal mosi      : std_logic;
    signal color_led : std_logic_vector (2 downto 0);
    signal data      : std_logic_vector (31 downto 0);
    signal an        : std_logic_vector (7 downto 0);
    signal cat       : std_logic_vector (6 downto 0);

    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : nexys4
    port map (clk       => clk,
              start     => start,
              rst       => rst,
              miso      => miso,
              ss        => ss,
              sclk      => sclk,
              mosi      => mosi,
              color_led => color_led,
              data      => data,
              an        => an,
              cat       => cat);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        start <= '0';
        rst <= '0';
        miso <= '0';
        wait for 10 ns;
        start <= '1';
        miso <= '1';
        -- EDIT Add stimuli here
        wait for 105ms;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
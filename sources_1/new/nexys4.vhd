library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity nexys4 is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           rst : in STD_LOGIC;
           miso : in STD_LOGIC;
           ss : out STD_LOGIC;
           sclk : out STD_LOGIC;
           mosi : out STD_LOGIC;
           color_led : out std_logic_vector (2 downto 0);
           data : out std_logic_vector(31 downto 0);
           an : out std_logic_vector (7 downto 0);
           cat : out std_logic_vector (6 downto 0));
end nexys4;
architecture Behavioral of nexys4 is
component FSM is
    Port ( start : in STD_LOGIC;
           reset : in STD_LOGIC;
           clk : in STD_LOGIC;
           sclk : out STD_LOGIC;
           miso : in STD_LOGIC;
           mosi : out STD_LOGIC;
           x : out STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
           y : out STD_LOGIC_VECTOR(15 downto 0):=(others => '0');
           ss_n : out STD_LOGIC);
end component;
    component ssd is
    Port (
        clk: in std_logic;
        data: in std_logic_vector(31 downto 0);
        cat: out std_logic_vector(6 downto 0);
        an: out std_logic_vector(7 downto 0)
    );
end component;

component tri_color_decoder is
    Port (
        clk : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR(31 downto 0);
        rgb_led_code : out STD_LOGIC_VECTOR(2 downto 0)
    );
end component;
signal sclk_internal : STD_LOGIC := '0';  -- Internal signal for sclk

    signal x_output, y_output : STD_LOGIC_VECTOR(15 downto 0);
    signal data_output : std_logic_vector (31 downto 0);
    signal rgb_led_output : STD_LOGIC_VECTOR(2 downto 0);
    signal cat_output : STD_LOGIC_VECTOR(6 downto 0);
    signal an_output : STD_LOGIC_VECTOR(7 downto 0);
    signal start_signal,rst_signal : std_logic:= '0';
begin
FSM_Instance: FSM
    port map (
        start => start_signal,
        reset => rst_signal,
        clk => clk,
        sclk => sclk_internal,
        miso => miso,
        mosi => mosi,
        x => x_output,
        y => y_output,
        ss_n => ss
    );
data_output <= x_output & y_output;
data <= data_output;
ssd_Instance: ssd
port map (
    clk => clk,
    data => data_output,  
    cat => cat_output,
    an => an_output
);
tri_color_decoder_Instance: tri_color_decoder
port map (
    clk => clk,
    data_in => data_output,  
    rgb_led_code => rgb_led_output
);
start_signal <= start;
rst_signal <= rst;
sclk<= sclk_internal;
cat <= cat_output;
an <= an_output;
color_led <= rgb_led_output;
end Behavioral;
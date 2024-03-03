library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tri_color_decoder is
    Port (
        clk          : in  STD_LOGIC;
        data_in      : in  STD_LOGIC_VECTOR (31 downto 0);
        rgb_led_code : out STD_LOGIC_VECTOR (2 downto 0)
    );
end tri_color_decoder;

architecture Behavioral of tri_color_decoder is
    signal counter : std_logic_vector(16 downto 0) := (others => '0');
    signal selection : STD_LOGIC_VECTOR(2 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
        end if;
    end process;

    -- Clock divider
    selection <= counter(16 downto 14);

    process(data_in)
    begin
        -- Default values
        rgb_led_code <= "000";

        -- Check x direction (bit 31)
        if data_in(31) = '1' then
            rgb_led_code(0) <= '1'; -- Red LED
        end if;

        -- Check y direction (bit 15)
        if data_in(15) = '1' then
            rgb_led_code(1) <= '1'; -- Green LED
        end if;

        -- Check diagonal directions (bit 31 and bit 15)
        if data_in(31) = '1' and data_in(15) = '1' then
            rgb_led_code(2) <= '1'; -- Blue LED
        end if;
    end process;
end Behavioral;

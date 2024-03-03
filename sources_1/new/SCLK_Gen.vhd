library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SCLK_Gen is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        enable : in STD_LOGIC;
        sclk : out STD_LOGIC;
        CE_p : out STD_LOGIC;
        CE_n : out STD_LOGIC
    );
end SCLK_Gen;

architecture Behavioral of SCLK_Gen is
    constant SYS_CLK_FREQUENCY : INTEGER := 100_000_000;
    constant SCLK_TARGET_FREQUENCY : INTEGER := 565_000;

    signal counter : INTEGER := 0;
    signal clock_period : INTEGER := integer(SYS_CLK_FREQUENCY / SCLK_TARGET_FREQUENCY);

    signal CE_p_internal : STD_LOGIC := '0';
    signal CE_n_internal : STD_LOGIC := '0';
    signal sclk_internal : STD_LOGIC := '0';

begin
    process(clk, reset)
    begin
        if reset = '1' then
            counter <= 0;
            CE_p_internal <= '0';
            CE_n_internal <= '0';
            sclk_internal <= '0';
        elsif rising_edge(clk) then
            if enable = '1' then
                counter <= counter + 1;

                -- sclk and CE_p go high at the same time
                if counter = (clock_period / 2) - 1 then
                    sclk_internal <= '1'; -- sclk goes high
                    CE_p_internal <= '1'; -- CE_p goes high
                elsif counter = (clock_period / 2) then
                    CE_p_internal <= '0'; -- CE_p goes l
                -- sclk and CE_n go low at the same time
                elsif counter = clock_period - 1 then
                    sclk_internal <= '0'; -- sclk goes low
                    CE_n_internal <= '1'; -- CE_n goes high
                elsif counter = clock_period then
                    counter <= 0;         -- Reset the counter for the next cycle
                    CE_p_internal <= '0'; -- Reset CE_p
                    CE_n_internal <= '0'; -- Reset CE_n
                end if;
            else
                counter <= 0;
                CE_p_internal <= '0';
                CE_n_internal <= '0';
                sclk_internal <= '0';
            end if;
        end if;
    end process;

    -- Output assignments
    sclk <= sclk_internal;
    CE_p <= CE_p_internal;
    CE_n <= CE_n_internal;
end Behavioral;

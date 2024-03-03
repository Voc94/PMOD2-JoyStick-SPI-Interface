----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/04/2023 06:28:54 PM
-- Design Name: 
-- Module Name: left_shift_reg - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity left_shift_reg is
    Port ( Sin : in STD_LOGIC;
           Sout : out STD_LOGIC:= '0';
           D : in STD_LOGIC_VECTOR (7 downto 0);
           Q : out STD_LOGIC_VECTOR (7 downto 0);
           clk : in STD_LOGIC;
           load : in STD_LOGIC;
           left_shift : in STD_LOGIC);
end left_shift_reg;

architecture Behavioral of left_shift_reg is
    signal value_stored : std_logic_vector(7 downto 0) := "00000000";

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if load = '1' then
                value_stored <= D;
            elsif left_shift = '1' then
                value_stored <= value_stored(6 downto 0) & Sin;
                Sout <= value_stored(7);
            end if;
        end if;
    end process;
    Q <= value_stored;
end Behavioral;
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/12/2026 01:32:03 PM
-- Design Name: 
-- Module Name: sd_transmitter - Behavioral
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

entity sd_receiver is
Port (
    clk_port : in std_logic;
    miso_port : in std_logic;
    data_port : out std_logic_vector(39 downto 0);
    load_en_port : in std_logic;
    shift_en_port : in std_logic

 );
end sd_receiver;



architecture Behavioral of sd_receiver is

signal shift_reg : std_logic_vector(39 downto 0) := (others => '0');
begin


shift_register: process(clk_port)
begin
    if falling_edge(clk_port) then
        if shift_en_port = '1' then
        
            shift_reg <= shift_reg(38 downto 0) & miso_port;
        end if;
        
        if load_en_port = '1' then
            data_port <= shift_reg;
        end if;
    end if;
end process;

end Behavioral;

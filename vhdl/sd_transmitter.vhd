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

entity sd_transmitter is
Port (
    clk_port : in std_logic;
    mosi_port : out std_logic;
    data_port : in std_logic_vector(47 downto 0);
    load_en_port : in std_logic;
    shift_en_port : in std_logic

 );
end sd_transmitter;



architecture Behavioral of sd_transmitter is

signal shift_reg : std_logic_vector(47 downto 0) := (others => '0');
begin


shift_register: process(clk_port)
begin
    if falling_edge(clk_port) then
        if shift_en_port = '1' then
        
            mosi_port <= shift_reg(0);
            shift_reg <= '0' & shift_reg(47 downto 1);
        end if;
        
        if load_en_port = '1' then
            shift_reg <= data_port;
        end if;
    end if;
end process;

end Behavioral;

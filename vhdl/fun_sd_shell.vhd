----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/12/2026 10:46:37 AM
-- Design Name: 
-- Module Name: fun_sd_shell - Behavioral
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

entity fun_sd_shell is
    Port (
        sd_cs_ext_port : out std_logic;
        sd_sck_ext_port : out std_logic;
        sd_mosi_ext_port : out std_logic;
        sd_miso_ext_port : out std_logic
     );
end fun_sd_shell;

architecture Behavioral of fun_sd_shell is

begin
    
    

end Behavioral;

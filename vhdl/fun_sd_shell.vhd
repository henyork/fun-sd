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

component sd_receiver is                                
    Port (                                              
    clk_port : in std_logic;                            
    miso_port : in std_logic;                           
    data_port : out std_logic_vector(39 downto 0);      
    full_port : out std_logic;                          
    reset_port : in std_logic                           
                                                        
 );                                                     
end component;                                          


component sd_transmitter is
    Port (
    clk_port : in std_logic;
    mosi_port : out std_logic;
    data_port : in std_logic_vector(0 to 47);
    start_port : in std_logic;
    idle_port : out std_logic
 );
 end component;

component system_clock_generator is
    generic (CLOCK_DIVIDER_RATIO : integer);
	port (
        input_clk_port		: in std_logic;
        system_clk_port	    : out std_logic;
		fwd_clk_port		: out std_logic);
end component;


begin
    
    
receiever : sd_receiever

port map(
    miso_port = > miso_ext_port,
    clk_port => system_clk,
    data_port => 
    start_port =>
    idle_port => 
    

end Behavioral;

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
        clk_ext_port : in std_logic;
        sd_cs_ext_port : out std_logic;
        sd_sck_ext_port : out std_logic;
        sd_mosi_ext_port : out std_logic;
        sd_miso_ext_port : in std_logic;
        led_ext_port : out std_logic;
        led1 : out std_logic;
        led2 : out std_logic;
        led3 : out std_logic
     );
end fun_sd_shell;

architecture Behavioral of fun_sd_shell is


signal start : std_logic := '0';
signal idle : std_logic := '0';
signal full : std_logic := '0';
signal reset : std_logic := '0';
signal full_data_rec : std_logic := '0';
signal reset_data_rec : std_logic := '0';
signal receiver_data   : std_logic_vector(0 to 39);
signal data : std_logic_vector (0 to 3839);
signal transmitter_data :std_logic_vector(0 to 47);
signal system_clk : std_logic := '0';

component SPI_SD_controller is
  Port (clk_port    : in std_logic;
        receiver_reg   : in std_logic_vector(0 to 39);
        idle_trans     : in std_logic;
        full_rec        : in std_logic;
        full_data_rec : in std_logic;
        data_reg : in std_logic_vector(0 to 39);
        CS_port     : out std_logic;
        start_en    :  out std_logic;
        reset       : out  std_logic;
        reset_data_rec_port : out std_logic;
        LED_EN      : out std_logic;
        command_port :   out std_logic_vector(0 to 47);
        led1 : out std_logic;
        led2 : out std_logic;
        led3 : out std_logic
 );
end component;

component sd_receiver is                                
    Port (                                              
    clk_port : in std_logic;                            
    miso_port : in std_logic;                           
    data_port : out std_logic_vector(0 to 39);      
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
 
 component sd_data_rec is                                
    Port (                                              
    clk_port : in std_logic;                            
    miso_port : in std_logic;                           
    data_port : out std_logic_vector(0 to 3839);      
    full_port : out std_logic;                          
    reset_port : in std_logic                           
                                         
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

controller : spi_sd_controller
port map(
    clk_port => system_clk,
    receiver_reg => receiver_data,
    idle_trans => idle,
    full_rec => full,
    full_data_rec => full_data_rec,
    data_reg => data,
    CS_port => sd_cs_ext_port,
    start_en => start,
    reset => reset,
    reset_data_rec_port => reset_data_rec,
    LED_EN => led_ext_port,
    command_port => transmitter_data,
    led1 => led1,
    led2 => led2,
    led3 => led3
);

clock_gen : system_clock_generator 
generic map(
    clock_divider_ratio => 100)
port map(
    input_clk_port => clk_ext_port,
    system_clk_port => system_clk,
    fwd_clk_port => sd_sck_ext_port
);

receiever : sd_receiver
port map(
    miso_port => sd_miso_ext_port,
    clk_port => system_clk,
    data_port => receiver_data,
    reset_port => reset,
    full_port => full
);

data_rec : sd_data_rec
port map(
    miso_port => sd_miso_ext_port,
    clk_port => system_clk,
    data_port => data,
    reset_port => reset_data_rec,
    full_port => full_data_rec
);

transmitter : sd_transmitter
port map(
    clk_port => system_clk,
    mosi_port => sd_mosi_ext_port,
    data_port => transmitter_data,
    start_port => start,
    idle_port => idle

);

end Behavioral;

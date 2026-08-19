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
        hsync : out std_logic;
        vsync : out std_logic;
        vgaRed : out std_logic_vector(0 to 1);
        vgaGreen : out std_logic_vector(0 to 1);
        vgaBlue : out std_logic_vector(0 to 1);
        reset_ext_port : in std_logic; -- this resets the vga controller
        led1 : out std_logic;
        led2 : out std_logic;
        led3 : out std_logic;
        led4 : out std_logic;
        led5 : out std_logic;
        led6 : out std_logic;
        reset_data_rec_ext_port : out std_logic
        
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
signal transmitter_data :std_logic_vector(0 to 47);
signal system_clk : std_logic := '0';
signal read_addr : std_logic_vector(8 downto 0) := (others => '0');
signal write_sel : std_logic := '0';
signal read_port : std_logic := '0';
signal reset_addr : std_logic := '0';
signal register_done : std_logic := '0';

component SPI_SD_controller is
  Port (clk_port    : in std_logic;
        receiver_reg   : in std_logic_vector(0 to 39);
        idle_trans     : in std_logic;
        full_rec        : in std_logic;
        full_data_rec : in std_logic;
        reset_addr_port : in std_logic;
        register_done_port : in std_logic;
        CS_port     : out std_logic;
        start_en    :  out std_logic;
        reset       : out  std_logic;
        reset_data_rec_port : out std_logic;
        LED_EN      : out std_logic;
        command_port :   out std_logic_vector(0 to 47);
        write_sel_port : out std_logic
        
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
    write_sel_port : in std_logic;
    read_port : out std_logic;
    reset_port : in std_logic;
    read_addr_port : in std_logic_vector(8 downto 0);
    full_port : out std_logic                        
                                
 );                                                     
end component;       

component system_clock_generator is
    generic (CLOCK_DIVIDER_RATIO : integer);
	port (
        input_clk_port		: in std_logic;
    
        system_clk_port	    : out std_logic;
		fwd_clk_port		: out std_logic);
end component;


component vga_controller is
    Port (
        clk_sys     : in  std_logic;
        reset       : in  std_logic;
        pixel_data  : in std_logic;
        
        pixel_address   : out std_logic_vector(11 downto 0);

        vgaRed     : out std_logic_vector(1 downto 0);
        vgaGreen    : out std_logic_vector(1 downto 0);
        vgaBlue     : out std_logic_vector(1 downto 0);

        Hsync      : out std_logic;
        Vsync      : out std_logic;
        pixel_request   : out std_logic;
        frame_done   : out std_logic
    );
end component;


begin



controller : spi_sd_controller
port map(
    clk_port => system_clk,
    receiver_reg => receiver_data,
    idle_trans => idle,
    full_rec => full,
    full_data_rec => full_data_rec,
    CS_port => sd_cs_ext_port,
    start_en => start,
    reset_addr_port => reset_addr,
    register_done_port => register_done,
    
    reset => reset, -- this is to reset the receiever
    reset_data_rec_port => reset_data_rec,
    LED_EN => led_ext_port,
    command_port => transmitter_data,
    write_sel_port => write_sel
);

clock_gen : system_clock_generator 
generic map(
    clock_divider_ratio => 4)
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
    read_port => read_port,
    read_addr_port => read_addr,
    write_sel_port => write_sel,
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

vga : vga_controller
port map(
    clk_sys => clk_ext_port,
    reset => reset_ext_port,
    pixel_data => read_port,
    pixel_address => read_addr,
    
    vgaRed => vgaRed,
    vgaGreen => vgaGreen,
    vgaBlue => vgaBlue,

    Hsync => Hsync,
    Vsync => Vsync,
    register_done => register_done,
    frame_done => reset_addr


);
reset_data_rec_ext_port <= reset_data_rec; --this is useful as a scope trigger, so it is output to an ext port

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/12/2026 03:58:57 PM
-- Design Name: 
-- Module Name: SPI_SD_controller_TB - Behavioral
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

entity SPI_SD_controller_TB is
end SPI_SD_controller_TB;

architecture testbench of SPI_SD_controller_TB is
component SPI_SD_controller is
  Port (clk_port    : in std_logic;
        receiver_reg   : in std_logic_vector(0 to 39);
        idle_trans     : in std_logic;
        full_rec        : in std_logic;
  
        CS_port     : out std_logic;
        start_en    :  out std_logic;
        reset       : out  std_logic;
        LED_EN      : out std_logic;
        command :   out std_logic_vector(0 to 47)
 );
end SPI_SD_controller;


constant clk_period : time := 10 ns; -- 100 MHz

 signal       clk_tb               : std_logic := '0';
 signal    `  receiver_reg_tb      : std_logic_vector(0 to 39) := (others => '0');
 signal       idle_trans_tb        : std_logic;
 signal       full_rec_tb          : std_logic;
  
  signal      CS_port_tb           : std_logic;
  signal      start_en_tb          : std_logic;
  signal      reset_tb             : std_logic;
  signal      LED_EN_tb            : std_logic;
  signal      command_tb           : std_logic_vector(0 to 47);



begin
DUT: entitiy spi_sd_controller
    port map (  clk_port        => slk_tb,
                receiver_reg    => receiver_reg_tb,  
                idle_trans      => idle_trans_tb,   
                full_rec        => full_rec_tb,    
  
                CS_port         => CS_port_tb, 
                start_en   `    => start_en_tb,
                reset           => reset_tb,
                LED_EN          => LED_EN_tb,
                command         => command_tb
 );

-- Clock process definitions
clk_process :process
begin
    clk_ext <= '0';
    wait for clk_period/2;
    clk_ext <= '1';
    wait for clk_period/2;
end process;



end Behavioral;



--=============================================================
--Ben Dobbins
--CS56/ENGS31 21S
--This script is the testbench code for Lab 4, the voltmeter.
--=============================================================
--=============================================================
--Library Declarations
--=============================================================
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

 --=============================================================
--Testbench Entity Declaration
--=============================================================
ENTITY spi_reciever_tb IS
END spi_reciever_tb;

--=============================================================
--Testbench declarations
--=============================================================
ARCHITECTURE testbench OF spi_reciever_tb IS 
component system_clock_generator is
    generic (CLOCK_DIVIDER_RATIO : integer:= 100);
	port (
        input_clk_port		: in std_logic;
        system_clk_port	    : out std_logic;
		fwd_clk_port		: out std_logic);
end component;

component tick_generator is
	generic (FREQUENCY_DIVIDER_RATIO : integer:= 100000);
	port (
		system_clk_port   : in  std_logic;
		tick_port		  : out std_logic);
end component;

component spi_receiver is
	generic(
		N_SHIFTS 			: integer := 15);
	port(
		clk_port			: in  std_logic;	--1 MHz serial clock
    	 
		take_sample_port 	: in  std_logic;	--controller signals
		spi_cs_port		    : out std_logic;

		spi_s_data_port	    : in  std_logic;	--datapath signals
		adc_data_port		: out std_logic_vector(11 downto 0));
end component; 

--=============================================================
--Local Signal Declaration
--=============================================================
signal clk_ext          : std_logic := '0';
signal system_clk       : std_logic := '0';
signal spi_s_data       : std_logic := '0';
signal take_sample      : std_logic := '0';
signal spi_sclk         : std_logic := '0' ;
signal spi_cs           : std_logic := '1';
signal adc_data         : std_logic_vector(11 downto 0) := (others => '0');

-- Clock period definitions
constant clk_period     : time := 10ns;		-- 100 MHz clock

-- Data definitions
constant TxData         : std_logic_vector(14 downto 0) := "000" & x"abc";
signal bit_count        : integer := 14;
	
BEGIN 

-- Instantiate the Unit Under Test (UUT) 
uut: spi_receiver
generic map(
	N_SHIFTS => 15)
port map(
	clk_port			=> system_clk,
	take_sample_port 	=> take_sample,
	spi_cs_port		    => spi_cs,
	spi_s_data_port	    => spi_s_data,
	adc_data_port		=> adc_data);	

clocking: system_clock_generator 
generic map(
	CLOCK_DIVIDER_RATIO =>  100)
port map(
	input_clk_port 		=> clk_ext,
	system_clk_port 	=> system_clk,
	fwd_clk_port		=> spi_sclk);

tick_generation: tick_generator
generic map(
	FREQUENCY_DIVIDER_RATIO => 100000)
port map( 
	system_clk_port 	=> system_clk,
	tick_port			=> take_sample);	

--=============================================================
--Timing:
--=============================================================		      
-- Clock process definitions
clk_process :process
begin
    clk_ext <= '0';
    wait for clk_period/2;
    clk_ext <= '1';
    wait for clk_period/2;
end process;

--=============================================================
--Stimulus Process:
--=============================================================		
--The testbench pretends to be the A/D converter
--The testbench is waiting for spi_sclk and spi_cs from the design
--The data line will be undefined until it receives these signals
--TxData is the internal register where a sample is stored
--Here, the sample loaded in TxData is: 000 1010 1011 1100
--Or abc. This process acts as the shift register in the ADC and sends
--abc one bit at a time to your shift register. 
--Your design is working properly if you recover abc in your adc_data register.
stim_proc: process(spi_sclk)
begin
if falling_edge(spi_sclk) then       -- clock data out on falling edge, MSB first		
    if spi_cs = '0' then		
        spi_s_data <= TxData(bit_count);
        if bit_count = 0 then bit_count <= 14;
        else bit_count <= bit_count - 1;
        end if;		
    else
        bit_count <= 14;
    end if;			
end if;
end process;
END;
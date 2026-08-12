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
ENTITY sd_transmitter_tb IS
END sd_transmitter_tb;

--=============================================================
--Testbench declarations
--=============================================================
ARCHITECTURE testbench OF sd_transmitter_tb IS 
component system_clock_generator is
    generic (CLOCK_DIVIDER_RATIO : integer);
	port (
        input_clk_port		: in std_logic;
        system_clk_port	    : out std_logic;
		fwd_clk_port		: out std_logic);
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

--=============================================================
--Local Signal Declaration
--=============================================================
signal clk_ext          : std_logic := '0';
signal system_clk       : std_logic := '0';
signal mosi : std_logic := '0';
signal spi_sclk         : std_logic := '0' ;
signal spi_cs           : std_logic := '1';
signal start : std_logic := '0';
signal idle : std_logic := '0';
signal data : std_logic_vector(0 to 47) := (others => '0');
-- Clock period definitions
constant clk_period     : time := 10ns;		-- 100 MHz clock

-- Data definitions
constant TxData         : std_logic_vector(0 to 47) := "0000" & x"bcabcabcab" & "1110";


	
BEGIN 

-- Instantiate the Unit Under Test (UUT) 
uut: sd_transmitter

port map(
	clk_port    => clk_ext,
	mosi_port 	=> mosi,
	data_port   => data,
	start_port  => start,
	idle_port => idle);

clocking: system_clock_generator 
generic map(
	CLOCK_DIVIDER_RATIO => 100)
port map(
	input_clk_port 		=> clk_ext,
	system_clk_port 	=> system_clk,
	fwd_clk_port		=> spi_sclk);


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
stim_proc: process
begin
    data <= TxData;
    wait for clk_period;
    start <= '1';
    wait for clk_period;
    start <= '0';
    wait for clk_period * 50;

end process;
END;
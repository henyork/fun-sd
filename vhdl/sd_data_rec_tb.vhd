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
ENTITY sd_data_rec_tb IS
END sd_data_rec_tb;

--=============================================================
--Testbench declarations
--=============================================================
ARCHITECTURE testbench OF sd_data_rec_tb IS 
component system_clock_generator is
    generic (CLOCK_DIVIDER_RATIO : integer);
	port (
        input_clk_port		: in std_logic;
        system_clk_port	    : out std_logic;
		fwd_clk_port		: out std_logic);
end component;


component sd_data_rec is
    Port (
     clk_port : in std_logic;
    miso_port : in std_logic;
    write_sel_port : in std_logic;
    read_port : out std_logic_vector(0 to 5);
    reset_port : in std_logic;
    read_addr_port : in std_logic_vector(8 downto 0);
    full_port : out std_logic

 );
end component;

--=============================================================
--Local Signal Declaration
--=============================================================
signal clk_ext          : std_logic := '0';
signal system_clk       : std_logic := '0';
signal miso : std_logic := '0';
signal spi_sclk         : std_logic := '0' ;
signal spi_cs           : std_logic := '1';
signal full : std_logic := '0';
signal reset : std_logic := '0';
signal data : std_logic_vector(0 to 5) := (others => '0');
signal read_addr : std_logic_vector(8 downto 0) := (others => '0');
signal write_sel : std_logic := '0'; 
-- Clock period definitions
constant clk_period     : time := 10ns;		-- 100 MHz clock

-- Data definitions
--constant TxData         : std_logic_vector(47 downto 0) := "1001" & x"bcabcabcab" & "1101";


	
BEGIN 

-- Instantiate the Unit Under Test (UUT) 
uut: sd_data_rec

port map(
	clk_port    => spi_sclk,
	miso_port 	=> miso,
	read_port   => data,
	reset_port  => reset,
	full_port => full,
	read_addr_port => read_addr,
	write_sel_port => write_sel
	);

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
    wait for clk_period*500;
    write_sel <= '1';
    wait for clk_period *500;
    read_addr <= "000000001";
    wait for clk_period * 500;
    write_sel <= '0';
    wait for clk_period * 500;
    read_addr <= "000000000";
    wait for clk_period * 500;
    reset <= '1';
    wait for clk_period*100;
    reset <= '0';
    wait for clk_period*500;
    miso <= '1';
    wait for clk_period * 200;
    miso <= '0';
    wait for clk_period * 300;
    miso <= '1';
    wait for clk_period * 300;
    miso <= '0';
    wait for clk_period * 500000;
    
     


end process;
END;
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
ENTITY sd_shell_tb IS
END sd_shell_tb;

--=============================================================
--Testbench declarations
--=============================================================
ARCHITECTURE testbench OF sd_shell_tb IS 

component fun_sd_shell is
Port (
        clk_ext_port : in std_logic;
        sd_cs_ext_port : out std_logic;
        sd_sck_ext_port : out std_logic;
        sd_mosi_ext_port : out std_logic;
        sd_miso_ext_port : in std_logic;
        led_ext_port : out std_logic
     );
end component;
--=============================================================
--Local Signal Declaration
--=============================================================
signal clk_ext          : std_logic := '0';
signal spi_clk : std_logic := '0';
signal led         : std_logic := '0' ;
signal cs         : std_logic := '1';
signal mosi : std_logic := '0';
signal miso : std_logic := '0';

-- Clock period definitions
constant clk_period     : time := 10ns;		-- 100 MHz clock
	
BEGIN 

-- Instantiate the Unit Under Test (UUT) 
uut: fun_sd_shell

port map(

	clk_ext_port => clk_ext,
    sd_cs_ext_port  => cs,
    sd_sck_ext_port  => spi_clk,
    sd_mosi_ext_port  => mosi,
    sd_miso_ext_port  => miso,
    led_ext_port => led);
	

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

    --when mosi goes low wait 60 clock cycles then output "000000001"
    
    wait until mosi <= '0';
    
    miso <= '1';
    wait for clk_period * 6000;
    miso <= '0';
    wait for clk_period * 700;
    miso <= '1';
    wait for clk_period * 100;
    
    


end process;
END;
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Peyton Acker
-- 
-- Create Date: 08/12/2026 01:34:07 PM
-- Design Name: 
-- Module Name: SPI_SD_controller - Behavioral
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

entity SPI_SD_controller is
  Port (
        clk_port : in std_logic;
        heard_reg : in std_logic_vector(39 downto 0);
  
        CS_port : out std_logic;
        out_shift_en:  out std_logic;
        in_shift_en : out  std_logic;
        load_en     : out std_logic;
        LED_EN      : out std_logic;
        command : out std_logic_vector(47 downto 0);

 );
end SPI_SD_controller;


architecture Behavioral of SPI_SD_controller is

--states here
type state is (idle, prep, load_CMD0, shift_command, read, check_read, works, failed);
signal current_state, next_state : state := idle;

--signals here
signal out_shift, in_shift :std_logic := '0';
signal command_CMD0 : std_logic_vector (47 downto 0) := "01" & (45 downto 40 => '0') & (39 downto 8 => '0') & 0x95;
signal prep_tc, read_tc, shift_tc : unsigned := "0000000";

begin

--clock
stateUpdate: process(clk_port) begin
    if rising_edge(clk_port) then
        current_state <= next_state;
    endif;
end process stateUpdate;

nextStateLog : process(prep_tc, read_tc. shift_tc, check_v) begin 
    next_state = current_state;
        
        case(current_state) is 
            when idle => 
                next_state <= prep;
            when prep =>
                if prep_tc = "1010000" then
                    next_state <= load_CMD0;
                else
                    next_state <= prep;
                endif;
            when load_CMD0 =>
                next_state <= shift_command;
            when shift_command =>
                if shift_tc = "0110000" then
                    next_state <= read;
                else    
                    next_state <= shift_command;
                endif;
            when read => 
                if read_tc = "0101000" then 
                    next_state <= check_read;
                else 
                    next_state <= read;
                endif;
            when check_read =>
                if heard_reg(47 downto 40) = "00000001" then
                    next_state <= works;
                else
                    next_state <= failed;
                endif;
            when works =>
                next_state <= works;
            when failed =>
                next_state <= failed;
            when others =>
                next_state <= idle;
        end case;
        
end process next_state_logic;



output_logic : process(current_state) begin 
out_shift <= '0';
in_shift <= '0';
load_en <= '0';
CS <= '1';
LED_EN <= '0';
command <= command_CMD0;

       case current_state is 
             when idle =>
             
            when prep =>
                CS_port <= '0'; 
                prep_tc <= prep_tc + 1;
            when load_CMD0 =>
                CS_port <= '0';
                load_en <= '1';
            when shift_command =>
                 CS_port <= '0';
                 load_en <= '0';
                 out_shift_en <= '1';
                 shift_tc <= shift_tc + 1;
            when read => 
                CS_port <= '0';
                out_shift_en <= '0';
                in_shift_en <= '1';
                read_tc <= read_tc + 1;
            when check_read =>
                CS_port <= '1';
            when works =>
                LED_EN <= '1';
            when failed =>
                LED_EN <= '0';
        end case;
end process output_logic;



end Behavioral;

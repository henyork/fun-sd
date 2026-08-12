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


architecture Behavioral of SPI_SD_controller is

--states here
type state is (prep, load_CMD0, start_shift, wait_full, check_read, works, failed);
signal currentstate, nextstate: state := prep;

--signals here

signal command_CMD0 : std_logic_vector (0 to 47) := "01" & (2 to 7 => '0') & (8 to 39 => '0') & x"95";
signal prep_tc : integer := 0;

begin
 
--clock
stateUpdate: process(clk_port) begin
    if rising_edge(clk_port) then
        currentstate <= nextstate;
    end if;
end process stateUpdate;

next_state_logic : process(prep_tc, idle_trans, full_rec) begin 
    nextstate <= currentstate;
        
        case(currentstate) is 
            when prep =>
                if prep_tc > 80 and idle_trans = '1' then
                    nextstate <= load_CMD0;
                else
                    nextstate <= prep;
                end if;
            when load_CMD0 =>
                nextstate <= start_shift;
            when start_shift =>
                nextstate <= wait_full;
            when wait_full => 
                if full_rec = '1' then 
                    nextstate <= check_read;
                else 
                    nextstate <= wait_full;
                end if;
            when check_read =>
                if receiver_reg(0 to 7) = "00000001" then
                    nextstate <= works;
                else
                    nextstate <= failed;
                end if;
            when works =>
                nextstate <= works;
            when failed =>
                nextstate <= failed;
        end case;
end process next_state_logic;



output_logic : process(currentstate) begin 
CS_port    <= '0';
start_en   <= '0';
reset      <= '0';
LED_EN     <= '0';
command <= (others => '0');

       case currentstate is 
            when load_CMD0 =>
                command <= command_CMD0;
                reset <= '1';
            when start_shift =>
                reset <= '0';
                start_en <= '1';
            when works =>
                LED_EN <= '1';
            when failed =>
                LED_EN <= '0';
        end case;
end process output_logic;

end Behavioral;

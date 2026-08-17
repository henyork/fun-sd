----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/12/2026 01:32:03 PM
-- Design Name: 
-- Module Name: sd_transmitter - Behavioral
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

entity sd_receiver is
Port (
    clk_port : in std_logic;
    miso_port : in std_logic;
    data_port : out std_logic_vector(0 to 39);
    reset_port : in std_logic;
    full_port : out std_logic

 );
end sd_receiver;



architecture Behavioral of sd_receiver is

type state_type is (idle, shift, full);
signal current_state, next_state : state_type := full;
signal shift_reg : std_logic_vector(0 to 38) := (others => '0');
signal shift_count : integer := 0;
signal tc : std_logic := '0';
signal shift_enable : std_logic := '0';
signal load_enable : std_logic := '0';
begin


state_update : process(clk_port)
begin
if rising_edge(clk_port) then
    current_state <= next_state;
end if;
end process;

next_state_logic : process(miso_port, reset_port, tc)
begin
next_state <= current_state;
    case current_state is
        when idle =>
            if miso_port = '0' then
                next_state <= shift;
            end if;
        when shift =>
            if tc = '1' then
                next_state <= full;
            end if;
         when full =>
            if reset_port = '1' then
                next_state <= idle;
            end if;
     end case;
end process;

output_logic : process(current_state)
begin
    case current_state is
        when idle =>
            full_port <= '0';
            shift_enable <= '0';
            load_enable <= '0';
        when shift =>
            full_port <= '0';
            shift_enable <= '1';
            load_enable <= '0';
        when full =>
            full_port <= '1';
            shift_enable <= '0';
            load_enable <= '1';
     end case;
end process;

shift_timer : process(clk_port)
begin
    if rising_edge(clk_port) then
        if shift_enable = '1' then
            shift_count <= shift_count + 1;
            
            if tc = '1' then
                shift_count <= 0;
            end if;
         end if;
     end if;
end process;

tc <= '1' when shift_count > 37 else '0';



shift_register: process(clk_port)
begin
    if rising_edge(clk_port) then
        if shift_enable = '1' then
        
            shift_reg <= shift_reg(1 to 38) & miso_port;
        end if;
        
        if load_enable = '1' then
            data_port <= '0' & shift_reg;
        end if;
    end if;
end process;

end Behavioral;

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
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sd_data_rec is
Port (
    clk_port : in std_logic;
    miso_port : in std_logic;
    write_sel_port : in std_logic;
    read_port : out std_logic_vector(0 to 5);
    reset_port : in std_logic;
    read_addr_port : in std_logic_vector(8 downto 0);
    full_port : out std_logic
    

 );
end sd_data_rec;



architecture Behavioral of sd_data_rec is

type state_type is (idle, shift, full);
signal current_state, next_state : state_type := full;
signal reg0 : std_logic_vector(0 to 4111) := "10100101" & (8 to 4111 => '0');
signal reg1 : std_logic_vector(0 to 4111) := "00011000" & (8 to 4111 => '0');

signal shift_count : integer := 0;
signal read_addr : integer := 0;
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
                shift_count <=  0;
            end if;
         end if;
     end if;
end process;

tc <= '1' when shift_count > 4110 else '0'; -- should be 3838



shift_register: process(clk_port)
begin
    if rising_edge(clk_port) then
        if shift_enable = '1' then
            if write_sel_port = '0' then
                reg0 <= reg0(1 to 4111) & miso_port;
            elsif write_sel_port = '1' then
                reg1 <= reg1(1 to 4111) & miso_port;
            end if;
        end if;
        
    end if;
end process;
read_addr <= to_integer(unsigned(read_addr_port));
shift_register_write: process(clk_port)
begin
    if falling_edge(clk_port) then
        
        
        if write_sel_port = '0' then
            read_port <= reg1(read_addr*6 to (read_addr*6)+5);

        elsif write_sel_port = '1' then
            read_port <= reg0(read_addr*6 to (read_addr*6)+5);
        end if;
        
    end if;
end process;


end Behavioral;

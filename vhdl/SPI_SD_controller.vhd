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
use IEEE.numeric_std.ALL;

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
        full_data_rec : in std_logic;
        register_done_port : in std_logic;
        reset_data_rec_port : out std_logic;
        enable_vga : out std_logic;
        CS_port     : out std_logic;
        start_en    :  out std_logic;
        reset       : out  std_logic;
        LED_EN      : out std_logic;
        command_port :   out std_logic_vector(0 to 47);
        write_sel_port : out std_logic;
        reset_sys_port : in std_logic
 );
end SPI_SD_controller;


architecture Behavioral of SPI_SD_controller is

--states here
type state is (reset_sys, prep, load_CMD0, load_CMD8, load_CMD55, load_CMD41, load_CMD16, check_CMD0, check_CMD8, check_CMD55, check_CMD41, check_CMD16, delay_CMD55, initialized, load_CMD17, check_CMD17, reset_data_rec, wait_data_rec_full, data_done,-- command specific states
start_shift, wait_idle, reset_receiver, wait_full, check_read, works, failed); -- generic states


signal currentstate, nextstate: state := reset_sys;

--signals here

constant command_CMD0 : std_logic_vector (0 to 47) := "01" & (2 to 7 => '0') & (8 to 39 => '0') & x"95";
constant command_CMD8 : std_logic_vector (0 to 47) := "01" & "001000" & x"000001AA" & x"87";
constant command_CMD55  : std_logic_vector (0 to 47) := "01" & "110111" & (8 to 39 => '0') & x"01"; --CHECKSUMS not changed
constant command_CMD41  : std_logic_vector (0 to 47) := "01" & "101001" & "01" & (10 to 39 => '0') & x"01";
constant command_CMD16 : std_logic_vector (0 to 47) := "01"  & "010000" & x"000001E0"  & x"01";

constant command_CMD17_start : std_logic_vector (0 to 7) := "01"  & "010001"; --changed to CMD 18
constant command_CMD17_csum : std_logic_vector (0 to 7) := x"01";
signal address : integer := 0;
signal address_vector : std_logic_vector(31 downto 0) := (31 downto 0 => '0');
signal command : std_logic_vector (0 to 47) := command_CMD0; -- set in load command state
signal stored_command : std_logic_vector (0 to 47) := command_CMD0; --stores the command in a flip flop
signal prep_tc : integer := 0;
signal wait_full_tc : integer := 0;
signal wait_cmd55_tc : integer := 0;
signal reset_counter : integer := 0;
signal write_sel : std_logic := '0';
signal enable_vga_signal: std_logic := '0';

begin
 
--clock
stateUpdate: process(clk_port) begin
    if rising_edge(clk_port) then
        currentstate <= nextstate;
    end if;
end process stateUpdate;

next_state_logic : process(currentstate, prep_tc, idle_trans, full_rec, wait_full_tc, wait_cmd55_tc, full_data_rec, register_done_port, reset_sys_port) begin 
    
 nextstate <= currentstate;
        case(currentstate) is 
            when reset_sys =>
                if reset_sys_port = '0' and reset_counter > 500000 then
                    nextstate <= prep;
                end if;
            when prep =>
                if prep_tc > 80 and idle_trans = '1' then
                    nextstate <= load_CMD0;
                else
                    nextstate <= prep;
                end if;
            when load_CMD0 =>
                nextstate <= start_shift;
            when load_CMD8 =>
                nextstate <= start_shift;
            when load_CMD55 =>
                nextstate <= start_shift;
            when load_CMD41 =>
                nextstate <= start_shift;
            when load_CMD16 =>
                nextstate <= start_shift;
            when load_CMD17 =>
                nextstate <= start_shift;
            when start_shift =>
                nextstate <= wait_idle;
            when wait_idle =>
                if idle_trans = '1' then
                    nextstate <= reset_receiver;
                else
                    nextstate <= wait_idle;
                end if;
            when reset_receiver =>
                nextstate <= wait_full;
            when wait_full => 
                if full_rec = '1' then 
                    if stored_command = command_CMD0 then
                        nextstate <= check_CMD0;
                    elsif stored_command = command_CMD8 then
                        nextstate <= check_CMD8;
                    elsif stored_command = command_CMD55 then
                        nextstate <= check_CMD55;
                    elsif stored_command = command_CMD41 then
                        nextstate <= check_CMD41;
                    elsif stored_command = command_CMD16 then
                        nextstate <= check_CMD16;
                    elsif stored_command(0 to 7) = command_CMD17_start then
                        nextstate <= check_CMD17;
                    else 
                        nextstate <= check_CMD0;
                    end if;
                elsif reset_sys_port = '1' then
                    nextstate <= reset_sys;
                elsif wait_full_tc > 100 then
                    nextstate <= reset_sys;
                end if;
            when check_CMD0 =>
                if receiver_reg(0 to 7) = "00000001" then
                    nextstate <= works;
                else
                    nextstate <= failed;
                end if;
            when check_CMD8 =>
                if receiver_reg(0 to 7) = "00000001" then
                    nextstate <= load_CMD55;
                else
                    nextstate <= prep;
                end if;
            when check_CMD55 =>
                if receiver_reg(0 to 7) = "00000001" then
                    nextstate <= load_CMD41;
                else
                    nextstate <= prep;
                end if;
            when check_CMD41 =>
                if receiver_reg(0 to 7) = "00000000" then
                    nextstate <= load_CMD16;
                elsif receiver_reg(0 to 7) = "00000001" then
                    nextstate <= delay_CMD55;
                else
                    nextstate <= prep;
                end if;
            when check_CMD16 =>
                if receiver_reg(0 to 7) = "00000000" then
                    nextstate <= load_CMD17;
                else
                    nextstate <= load_CMD16;
                end if;
            when check_CMD17 =>
                if receiver_reg(0 to 7) = "00000000" then
                    nextstate <= reset_data_rec;
                else
                    nextstate <= load_CMD17;
                end if;
           when data_done =>
                    
                    
                nextstate <= load_CMD17;
                if reset_sys_port = '1' then
                    nextstate <= reset_sys;
                end if;
                    
                    -- toggling write sel is handled in a separate flip flop to avoid latches
            when reset_data_rec => 
                nextstate <= wait_data_rec_full;
            when wait_data_rec_full =>
                
                if full_data_rec = '1' and register_done_port = '1' then
                    nextstate <= data_done;
                elsif full_data_rec = '1' and enable_vga_signal = '0' then
                    nextstate <= data_done;
                end if;
                if reset_sys_port = '1' then
                      nextstate <= reset_sys;
                end if;
                
            
            when works =>
                nextstate <= load_CMD8;
            when failed =>
                nextstate <= prep;
            when delay_CMD55 =>
                if wait_cmd55_tc > 100 then
                    nextstate <= load_CMD55;
                end if;
            when initialized =>
                null;
                --nextstate <= prep;
            when others =>
                null;
        end case;
        
end process next_state_logic;

write_sel_port <= write_sel;

output_logic : process(currentstate) begin 
CS_port    <= '0';
start_en   <= '0';
reset      <= '0';
LED_EN     <= '0';
reset_data_rec_port <= '0';
command <= (others => '0');
command_port <= (others => '0');


       case currentstate is 

            when start_shift =>
                command_port <= stored_command;
                reset <= '0';
                start_en <= '1';
            when reset_receiver =>
                reset <= '1';
            when wait_data_rec_full =>
                LED_EN <= '1';
            when reset_data_rec =>
                reset_data_rec_port <= '1';
            
            when others =>
                null;
                --do nothing
        end case;
end process output_logic;

counter : process(clk_port) begin
    if rising_edge(clk_port) then
        if currentstate = prep then
            prep_tc <= prep_tc +1;
        else
            prep_tc <= 0;
        end if;
        
        if currentstate = wait_full then
            wait_full_tc <= wait_full_tc +1;
        else
            wait_full_tc <=0;
        end if;
        
        if currentstate = delay_CMD55 then
            wait_cmd55_tc <= wait_cmd55_tc +1;
        else    
            wait_cmd55_tc <= 0;
        end if;
        
        if currentstate = reset_sys then 
           reset_counter <= reset_counter + 1;
           if reset_sys_port = '1' then
                reset_counter <= 0;
           end if;
        end if;
        
        
    end if;
 end process;
 
command_flipflop : process(clk_port) begin -- store the current command during the load state
    if falling_edge(clk_port) then
        if currentstate = load_cmd0 then
            stored_command <= command_CMD0;
            
        elsif currentstate = load_cmd8 then
            stored_command <= command_CMD8;
        elsif currentstate = load_cmd55 then
            stored_command <= command_CMD55;
        elsif currentstate = load_cmd41 then
            stored_command <= command_CMD41;
        elsif currentstate = load_cmd16 then
            stored_command <= command_CMD16;
        elsif currentstate = load_cmd17 then
            stored_command <= command_CMD17_start & address_vector & command_CMD17_csum;
        end if;

        
        if currentstate = data_done then
            write_sel <= not write_sel;
            enable_vga_signal <= '1';
            address <= address + 1;
        end if;
        
        if currentstate = prep or currentstate = reset_sys then
            enable_vga_signal <= '0';
            write_sel <= '0';
            address <= 0;
        end if;

    end if;
end process;
address_vector <= std_logic_vector(to_unsigned(address,32));
enable_vga <= enable_vga_signal;
end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Peyton Acker
-- 
-- Create Date: 08/14/2026 02:18:44 PM
-- Design Name: 
-- Module Name: VGA_controller_Acker - Behavioral
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_controller is
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
        register_done   : out std_logic;
        frame_done   : out std_logic
    );
end vga_controller;


ARCHITECTURE Behavioral of vga_controller is

-- Horizontal timing
    constant h_active       : integer := 640;
    constant h_front_porch  : integer := 16;
    constant h_sync         : integer := 96;
    constant h_back_porch   : integer := 48;
    constant h_total        : integer := 800;

    -- Vertical timing
    constant v_active       : integer := 480;
    constant v_front_porch  : integer := 10;
    constant v_sync         : integer := 2;
    constant v_back_porch   : integer := 33;
    constant v_total        : integer := 525;
    
    -- image width constants
    constant image_width : integer := 204;
    constant image_height : integer := 480;
    constant image_Xstart : integer := 218;
    constant image_Xstop  : integer := 421;
    constant image_Ystart : integer := 0;
    constant image_Ystop  : integer := 479;
    

   --counters 
    signal h_count : unsigned(9 downto 0) := (others => '0');
    signal v_count : unsigned(9 downto 0) := (others => '0');
    signal pixel_count : unsigned(11 downto 0) := (others => '0');

   --pixel clock

    signal clock_count : unsigned(1 downto 0) := (others => '0');
    signal pixel_tick  : std_logic := '0';



begin

   --converts system clock to pixel clock 
    process(clk_sys)
    begin
        if rising_edge(clk_sys) then
            if reset = '1' then
                clock_count <= (others => '0');
                pixel_tick  <= '0';
            else
                if clock_count = "11" then
                    clock_count <= (others => '0');
                    pixel_tick  <= '1';
                else
                    clock_count <= clock_count + 1;
                    pixel_tick  <= '0';
                end if;
            end if;
        end if;
    end process;

--counters 
    process(clk_sys)
    begin
        if rising_edge(clk_sys) then
            if reset = '1' then
                h_count <= (others => '0');
                v_count <= (others => '0');
            elsif pixel_tick = '1' then
              --horzontal counter 
                if h_count = H_TOTAL - 1 then
                    h_count <= (others => '0');
                   --increment vertricle coutner when end of horzontal coutner 
                    if v_count = V_TOTAL - 1 then
                        v_count <= (others => '0');
                    else
                        v_count <= v_count + 1;
                    end if;
                else
                    h_count <= h_count + 1;
                end if;
                
                -- only increment pixel address counter if within region
                if (h_count >= image_Xstart) and 
                (h_count <= image_Xstop) and 
                (v_count >= image_YStart) and 
                (v_count <= image_Ystop) then
                    pixel_count <= pixel_count + 1;
                end if;
                -- resets counter after reaches max pixels in the register
                if  pixel_count <= "111111110000" then
                    pixel_count <= (others => '0');
                end if;
                
            end if;
        end if;
    end process;


--bit enable horizontal 
    process(h_count)
    begin
        if (h_count >= H_ACTIVE + H_FRONT_PORCH) and
           (h_count <  H_ACTIVE + H_FRONT_PORCH + H_SYNC) then
            Hsync <= '0';
        else
            Hsync <= '1';
        end if;
    end process;
    
    
 --bit enable verticle
    process(v_count)
    begin
        if (v_count >= V_ACTIVE + V_FRONT_PORCH) and
           (v_count <  V_ACTIVE + V_FRONT_PORCH + V_SYNC) then
            Vsync <= '0';
        else
            Vsync <= '1';
        end if;
            
    end process;


--pixel generator 
    process(h_count, v_count)
    begin
    
        frame_done <= '0';
        register_done <= '0';
        vgaRed   <= "00";
        vgaGreen   <= "00";
        vgaBlue   <= "00";
        
        --check for image being almost done
        if v_count = v_total - 1 then
            frame_done <= '1';
        end if;
        
        --check for register being full 
        if pixel_count = "111111110000" then 
            register_done <= '1';
        else 
            register_done <= '0';
        end if;
       
       
       -- sends the location of the current pixel to the memory block
        pixel_address <= std_logic_vector(pixel_count);

    --if in active region it will send out color 
        if (h_count >= image_Xstart) and 
           (h_count <= image_Xstop) and 
           (v_count >= image_YStart) and 
           (v_count <= image_Ystop) then
           
        pixel_count <= pixel_count + 1;
        
        if pixel_data = '1' then 
             vgaRed   <= "11";
             vgaGreen   <= "11";
             vgaBlue   <= "11";
        else 
             vgaRed   <= "00";
             vgaGreen   <= "00";
             vgaBlue   <= "00";
        end if;
                -- during active prjecting for 2 bit color 
                --vgaRed <= pixel_data(5 downto 4);
                --vgaGreen <= pixel_data(3 downto 2);
                --vgaBlue <= pixel_data(1 downto 0);
         
        end if;
    end process;
end Behavioral;



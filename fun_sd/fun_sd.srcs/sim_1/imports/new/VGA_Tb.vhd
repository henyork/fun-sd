library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- VGA Controller for Basys 3
-- Version 1: 640x480 @ approximately 60 Hz
-- Input clock: 100 MHz
-- Pixel timing: 25 MHz using a clock-enable (no generated fabric clock)
-- Color: RGB444, 4 bits per color
--
-- Test image:
--   Top-left     = Red
--   Top-right    = Green
--   Bottom-left  = Blue
--   Bottom-right = White

entity vga_controller is
    Port (
        clk_sys : in  std_logic;
        reset      : in  std_logic;

        vgaRed     : out std_logic_vector(3 downto 0);
        vgaGreen   : out std_logic_vector(3 downto 0);
        vgaBlue    : out std_logic_vector(3 downto 0);

        Hsync      : out std_logic;
        Vsync      : out std_logic
    );
end vga_controller;

architecture Behavioral of vga_controller is

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

    -- Divide 100 MHz by 4 to obtain a 25 MHz pixel timing enable.
    signal clk_div : unsigned(1 downto 0) := (others => '0');

    -- 10 bits are sufficient for 0..799 and 0..524.
    signal h_count : unsigned(9 downto 0) := (others => '0');
    signal v_count : unsigned(9 downto 0) := (others => '0');

begin

    --------------------------------------------------------------------
    -- Timing counters
    --
    -- The FPGA remains clocked at 100 MHz. Every fourth clock advances
    -- the VGA timing counters, giving an effective 25 MHz pixel rate.
    --------------------------------------------------------------------
    process(clk_sys)
    begin
        if rising_edge(clk_sys) then

            if reset = '1' then
                clk_div <= (others => '0');
                h_count <= (others => '0');
                v_count <= (others => '0');

            elsif clk_div = "11" then
                clk_div <= (others => '0');

                -- Horizontal counter
                if h_count = H_TOTAL - 1 then
                    h_count <= (others => '0');

                    -- Advance vertical counter at end of each line.
                    if v_count = V_TOTAL - 1 then
                        v_count <= (others => '0');
                    else
                        v_count <= v_count + 1;
                    end if;

                else
                    h_count <= h_count + 1;
                end if;

            else
                clk_div <= clk_div + 1;
            end if;

        end if;
    end process;

    --------------------------------------------------------------------
    -- Horizontal sync
    -- Standard VGA sync polarity is active-low.
    --------------------------------------------------------------------
    process(h_count)
        variable h : integer;
    begin
        h := to_integer(h_count);

        if (h >= H_ACTIVE + H_FRONT_PORCH) and
           (h <  H_ACTIVE + H_FRONT_PORCH + H_SYNC) then
            Hsync <= '0';
        else
            Hsync <= '1';
        end if;
    end process;

    --------------------------------------------------------------------
    -- Vertical sync
    -- Standard VGA sync polarity is active-low.
    --------------------------------------------------------------------
    process(v_count)
        variable v : integer;
    begin
        v := to_integer(v_count);

        if (v >= V_ACTIVE + V_FRONT_PORCH) and
           (v <  V_ACTIVE + V_FRONT_PORCH + V_SYNC) then
            Vsync <= '0';
        else
            Vsync <= '1';
        end if;
    end process;

    --------------------------------------------------------------------
    -- Four-quadrant pixel generator
    --
    -- Color is driven only during the 640x480 active video region.
    -- During front porch, sync, and back porch the RGB outputs are black.
    --------------------------------------------------------------------
    process(h_count, v_count)
        variable h : integer;
        variable v : integer;
    begin
        h := to_integer(h_count);
        v := to_integer(v_count);

        -- Default: black outside active video.
        vgaRed   <= "0000";
        vgaGreen <= "0000";
        vgaBlue  <= "0000";

        if (h < H_ACTIVE) and (v < V_ACTIVE) then

            -- Top-left: Red
            if (h < 320) and (v < 240) then
                vgaRed   <= "1111";
                vgaGreen <= "0000";
                vgaBlue  <= "0000";

            -- Top-right: Green
            elsif (h >= 320) and (v < 240) then
                vgaRed   <= "0000";
                vgaGreen <= "1111";
                vgaBlue  <= "0000";

            -- Bottom-left: Blue
            elsif (h < 320) and (v >= 240) then
                vgaRed   <= "0000";
                vgaGreen <= "0000";
                vgaBlue  <= "1111";

            -- Bottom-right: White
            else
                vgaRed   <= "1111";
                vgaGreen <= "1111";
                vgaBlue  <= "1111";
            end if;
        end if;
    end process;

end Behavioral;

------------------------------------------------------------------------------
-- The MIT License (MIT)
--
-- Copyright (c) <2013> <Shimafuji Electric Inc., Osaka University, JAXA>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ftlib.all;

entity SpaceWireRouterIPRam32x256 is
    generic(
        tech : integer
    );
    port(
        clock       : in  std_logic;
        writeData   : in  std_logic_vector(31 downto 0);
        address     : in  std_logic_vector(7 downto 0);
        writeEnable : in  std_logic;
        chipEnable  : in  std_logic;
        readData    : out std_logic_vector(31 downto 0);
        testen      : in  std_logic);
end entity SpaceWireRouterIPRam32x256;

architecture behavioral of SpaceWireRouterIPRam32x256 is
    type mem_t is array (0 to 255) of std_logic_vector(31 downto 0);
    signal mem : mem_t;
    component hcmos8d_sp_0128x08m16
        port(
            Q   : out std_logic_vector(7 downto 0);
            A   : in  std_logic_vector(6 downto 0);
            CEN : in  std_logic;
            CLK : in  std_logic;
            D   : in  std_logic_vector(7 downto 0);
            WEN : in  std_logic
        );
    end component hcmos8d_sp_0128x08m16;
begin

    use_generic_tech : if tech = 0 generate
        process(clock) is
        begin                           -- process
            if rising_edge(clock) then
                readData <= mem(to_integer(unsigned(address)));
                if writeEnable = '1' then
                    mem(to_integer(unsigned(address))) <= writeData;
                end if;
            end if;
        end process;
    end generate use_generic_tech;

    use_hcmos8d_tech : if tech = 1 generate
        blk_hcmos8d_tech : block
            signal hcmos8d_active     : std_logic;
            signal hcmos8d_inactive   : std_logic;
            signal hcmos8d_data_in    : std_logic_vector(95 downto 0);
            signal hcmos8d_data_out_l : std_logic_vector(95 downto 0);
            signal hcmos8d_data_out_h : std_logic_vector(95 downto 0);
            signal hcmos8d_data_out   : std_logic_vector(95 downto 0);
            signal hcmos8d_cen_l      : std_logic;
            signal hcmos8d_cen_h      : std_logic;
            signal hcmos8d_cen        : std_logic;
            signal hcmos8d_wen        : std_logic;
        begin
            hcmos8d_active   <= '0';
            hcmos8d_inactive <= '1';
            loop_lower_ram : for i in 0 to 11 generate
                ul : component hcmos8d_sp_0128x08m16
                    port map(
                        Q   => hcmos8d_data_out_l(95 - 8 * i downto 88 - 8 * i),
                        A   => address(6 downto 0),
                        CEN => hcmos8d_cen_l,
                        CLK => clock,
                        D   => hcmos8d_data_in(95 - 8 * i downto 88 - 8 * i),
                        WEN => hcmos8d_wen
                    );
            end generate loop_lower_ram;
            loop_upper_ram : for i in 0 to 11 generate
                uh : component hcmos8d_sp_0128x08m16
                    port map(
                        Q   => hcmos8d_data_out_h(95 - 8 * i downto 88 - 8 * i),
                        A   => address(6 downto 0),
                        CEN => hcmos8d_cen_h,
                        CLK => clock,
                        D   => hcmos8d_data_in(95 - 8 * i downto 88 - 8 * i),
                        WEN => hcmos8d_wen
                    );
            end generate loop_upper_ram;
            hcmos8d_wen      <= hcmos8d_inactive when testen = '1' else (not writeEnable);
            hcmos8d_cen      <= hcmos8d_inactive when testen = '1' else (not chipEnable);
            hcmos8d_cen_l    <= hcmos8d_cen when (address(7) = '0') else hcmos8d_inactive;
            hcmos8d_cen_h    <= hcmos8d_cen when (address(7) = '1') else hcmos8d_inactive;
            hcmos8d_data_out <= hcmos8d_data_out_l when (address(7) = '0') else
                                hcmos8d_data_out_h;
            hcmos8d_data_in  <= writeData & writeData & writeData;
            readData         <= writeData when testen = '1' else
                                mvote(
                                    hcmos8d_data_out(95 downto 64),
                                    hcmos8d_data_out(63 downto 32),
                                    hcmos8d_data_out(31 downto 0));
        end block blk_hcmos8d_tech;

    end generate use_hcmos8d_tech;

end behavioral;

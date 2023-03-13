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
use work.testlib.all;

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
        testen      : in  std_logic;
        mi          : in  memdbg_in_t;
        mo          : out memdbg_out_t
    );
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
            signal hcmos8d_address    : std_logic_vector(6 downto 0);
            signal hcmos8d_data_in    : std_logic_vector(191 downto 0);
            signal hcmos8d_data_out   : std_logic_vector(191 downto 0);
            signal hcmos8d_data_l_out : std_logic_vector(31 downto 0);
            signal hcmos8d_data_h_out : std_logic_vector(31 downto 0);
            signal hcmos8d_cen        : std_logic_vector(23 downto 0);
            signal hcmos8d_wen        : std_logic_vector(23 downto 0);
        begin
            loop_ram : for i in 0 to 23 generate
                ul : component hcmos8d_sp_0128x08m16
                    port map(
                        Q   => hcmos8d_data_out(191 - 8 * i downto 184 - 8 * i),
                        A   => hcmos8d_address,
                        CEN => hcmos8d_cen(i),
                        CLK => clock,
                        D   => hcmos8d_data_in(191 - 8 * i downto 184 - 8 * i),
                        WEN => hcmos8d_wen(i)
                    );
                hcmos8d_data_in(191 - 8 * i downto 184 - 8 * i) <= mi.d when testen = '1' else
                                                                   writeData(31 - 8 * (i mod 4) downto 24 - 8 * (i mod 4));

                hcmos8d_cen(i) <= mi.cen(i) when testen = '1' else
                                  (not (chipEnable and (not address(7)))) when (i < 12) else
                                  (not (chipEnable and (address(7))));
                hcmos8d_wen(i) <= mi.wen(i) when testen = '1' else
                                  not writeEnable;

                mo.q(i) <= hcmos8d_data_out(191 - 8 * i downto 184 - 8 * i);
            end generate loop_ram;

            has_unused_outputs : if N_MODULES > 24 generate
                unused_outputs : for i in 24 to N_MODULES - 1 generate
                    mo.q(i) <= (others => '0');
                end generate unused_outputs;
            end generate has_unused_outputs;

            hcmos8d_address    <= mi.a when testen = '1' else address(6 downto 0);
            hcmos8d_data_l_out <= mvote(
                hcmos8d_data_out(191 downto 160),
                hcmos8d_data_out(159 downto 128),
                hcmos8d_data_out(127 downto 96));
            hcmos8d_data_h_out <= mvote(
                hcmos8d_data_out(95 downto 64),
                hcmos8d_data_out(63 downto 32),
                hcmos8d_data_out(31 downto 0));

            readData <= writeData when testen = '1' else
                        hcmos8d_data_l_out when address(7) = '0' else
                        hcmos8d_data_h_out;

        end block blk_hcmos8d_tech;

    end generate use_hcmos8d_tech;

end behavioral;

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

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity SpaceWireRouterIPStatisticCounter is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        counterClear : in  std_logic;
        countEnable  : in  std_logic;
        count        : out std_logic_vector (15 downto 0)
        );
end SpaceWireRouterIPStatisticCounter;

architecture behavioral of SpaceWireRouterIPStatisticCounter is

    signal iCount : std_logic_vector (15 downto 0);

begin

----------------------------------------------------------------------
-- 16Bit counter which counts clock synchronization One Shot Pulse
-- It could count up to 0xFFFF (65534).
----------------------------------------------------------------------
    process (clock, reset)
    begin
        if (reset = '1') then
            iCount <= (others => '0');
        elsif (clock'event and clock = '1') then
            if (counterClear = '1') then
                iCount <= (others => '0');
            elsif (countEnable = '1') then
                if (iCount /= x"ffff") then
                    iCount <= iCount + 1;
                end if;
            end if;
        end if;
    end process;

    count <= iCount;

end behavioral;

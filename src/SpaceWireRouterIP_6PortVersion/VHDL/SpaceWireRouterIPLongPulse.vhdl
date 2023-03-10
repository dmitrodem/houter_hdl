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

entity SpaceWireRouterIPLongPulse is
    port(
        clock        : in  std_logic;
        reset        : in  std_logic;
        pulseIn      : in  std_logic;
        longPulseOut : out std_logic
    );
end SpaceWireRouterIPLongPulse;

architecture behavioral of SpaceWireRouterIPLongPulse is

    signal iClockCount   : unsigned(7 downto 0);
    signal iLongPulseOut : std_logic;

begin

    ----------------------------------------------------------------------
    -- Convert synchronized One Shot Pulse into LongPulse.
    ----------------------------------------------------------------------
    process(clock, reset)
    begin
        if (reset = '1') then
            iClockCount   <= (others => '0');
            iLongPulseOut <= '0';
        elsif (clock'event and clock = '1') then
            if (pulseIn = '1') then
                iLongPulseOut <= '1';
            end if;
            if (iClockCount = x"ff") then
                iClockCount   <= (others => '0');
                iLongPulseOut <= '0';
            elsif (iLongPulseOut = '1') then
                iClockCount <= iClockCount + 1;
            end if;
        end if;
    end process;

    longPulseOut <= iLongPulseOut;

end behavioral;

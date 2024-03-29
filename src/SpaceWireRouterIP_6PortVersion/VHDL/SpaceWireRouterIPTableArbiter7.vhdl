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
-- [[[cog
-- n = int(nports) + 1
-- ]]]
-- [[[end]]]

library ieee;
use ieee.std_logic_1164.all;

entity SpaceWireRouterIPTableArbiter7 is
    port(
        clock   : in  std_logic;
        reset   : in  std_logic;
        -- [[[cog
        -- print(f"request : in  std_logic_vector({n} downto 0);")
        -- print(f"granted : out std_logic_vector({n} downto 0)")
        -- ]]]
        request : in  std_logic_vector(7 downto 0);
        granted : out std_logic_vector(7 downto 0)
        -- [[[end]]]
    );
end SpaceWireRouterIPTableArbiter7;

architecture behavioral of SpaceWireRouterIPTableArbiter7 is

    -- [[[cog
    -- print(f"signal iGranted : std_logic_vector({n} downto 0);")
    -- ]]]
    signal iGranted : std_logic_vector(7 downto 0);
    -- [[[end]]]

    ----------------------------------------------------------------------
    -- ECSS-E-ST-50-12C 10.2.5 Arbitration
    -- Two or more input ports can all be waiting to send data out of the same
    -- output port: SpaceWire routing switches shall provide a means of
    -- arbitrating between input ports requesting the same a routing table or
    -- a register.
    -- Packet based (EOP,EEP and TIMEOUT) arbitration schemes is implemented.
    ----------------------------------------------------------------------
begin
    process(clock, reset)
    begin
        if (reset = '1') then
            iGranted <= (0 => '1', others => '0');
        elsif (clock'event and clock = '1') then
            -- [[[cog
            -- for j in range(0, n+1):
            --   print(f"{'if' if j == 0 else 'elsif'} (iGranted({j}) = '1' and request({j}) = '0') then")
            --   for i in range(1, n+1):
            --     ii = (i + j) % (n + 1)
            --     print(f"    {'if' if i==1 else 'elsif'} (request({ii}) = '1') then")
            --     print(f"        iGranted <= \"{1<<ii:0{n+1}b}\";")
            --   print("    end if;")
            -- print("end if;")
            -- ]]]
            if (iGranted(0) = '1' and request(0) = '0') then
                if (request(1) = '1') then
                    iGranted <= "00000010";
                elsif (request(2) = '1') then
                    iGranted <= "00000100";
                elsif (request(3) = '1') then
                    iGranted <= "00001000";
                elsif (request(4) = '1') then
                    iGranted <= "00010000";
                elsif (request(5) = '1') then
                    iGranted <= "00100000";
                elsif (request(6) = '1') then
                    iGranted <= "01000000";
                elsif (request(7) = '1') then
                    iGranted <= "10000000";
                end if;
            elsif (iGranted(1) = '1' and request(1) = '0') then
                if (request(2) = '1') then
                    iGranted <= "00000100";
                elsif (request(3) = '1') then
                    iGranted <= "00001000";
                elsif (request(4) = '1') then
                    iGranted <= "00010000";
                elsif (request(5) = '1') then
                    iGranted <= "00100000";
                elsif (request(6) = '1') then
                    iGranted <= "01000000";
                elsif (request(7) = '1') then
                    iGranted <= "10000000";
                elsif (request(0) = '1') then
                    iGranted <= "00000001";
                end if;
            elsif (iGranted(2) = '1' and request(2) = '0') then
                if (request(3) = '1') then
                    iGranted <= "00001000";
                elsif (request(4) = '1') then
                    iGranted <= "00010000";
                elsif (request(5) = '1') then
                    iGranted <= "00100000";
                elsif (request(6) = '1') then
                    iGranted <= "01000000";
                elsif (request(7) = '1') then
                    iGranted <= "10000000";
                elsif (request(0) = '1') then
                    iGranted <= "00000001";
                elsif (request(1) = '1') then
                    iGranted <= "00000010";
                end if;
            elsif (iGranted(3) = '1' and request(3) = '0') then
                if (request(4) = '1') then
                    iGranted <= "00010000";
                elsif (request(5) = '1') then
                    iGranted <= "00100000";
                elsif (request(6) = '1') then
                    iGranted <= "01000000";
                elsif (request(7) = '1') then
                    iGranted <= "10000000";
                elsif (request(0) = '1') then
                    iGranted <= "00000001";
                elsif (request(1) = '1') then
                    iGranted <= "00000010";
                elsif (request(2) = '1') then
                    iGranted <= "00000100";
                end if;
            elsif (iGranted(4) = '1' and request(4) = '0') then
                if (request(5) = '1') then
                    iGranted <= "00100000";
                elsif (request(6) = '1') then
                    iGranted <= "01000000";
                elsif (request(7) = '1') then
                    iGranted <= "10000000";
                elsif (request(0) = '1') then
                    iGranted <= "00000001";
                elsif (request(1) = '1') then
                    iGranted <= "00000010";
                elsif (request(2) = '1') then
                    iGranted <= "00000100";
                elsif (request(3) = '1') then
                    iGranted <= "00001000";
                end if;
            elsif (iGranted(5) = '1' and request(5) = '0') then
                if (request(6) = '1') then
                    iGranted <= "01000000";
                elsif (request(7) = '1') then
                    iGranted <= "10000000";
                elsif (request(0) = '1') then
                    iGranted <= "00000001";
                elsif (request(1) = '1') then
                    iGranted <= "00000010";
                elsif (request(2) = '1') then
                    iGranted <= "00000100";
                elsif (request(3) = '1') then
                    iGranted <= "00001000";
                elsif (request(4) = '1') then
                    iGranted <= "00010000";
                end if;
            elsif (iGranted(6) = '1' and request(6) = '0') then
                if (request(7) = '1') then
                    iGranted <= "10000000";
                elsif (request(0) = '1') then
                    iGranted <= "00000001";
                elsif (request(1) = '1') then
                    iGranted <= "00000010";
                elsif (request(2) = '1') then
                    iGranted <= "00000100";
                elsif (request(3) = '1') then
                    iGranted <= "00001000";
                elsif (request(4) = '1') then
                    iGranted <= "00010000";
                elsif (request(5) = '1') then
                    iGranted <= "00100000";
                end if;
            elsif (iGranted(7) = '1' and request(7) = '0') then
                if (request(0) = '1') then
                    iGranted <= "00000001";
                elsif (request(1) = '1') then
                    iGranted <= "00000010";
                elsif (request(2) = '1') then
                    iGranted <= "00000100";
                elsif (request(3) = '1') then
                    iGranted <= "00001000";
                elsif (request(4) = '1') then
                    iGranted <= "00010000";
                elsif (request(5) = '1') then
                    iGranted <= "00100000";
                elsif (request(6) = '1') then
                    iGranted <= "01000000";
                end if;
            end if;
            -- [[[end]]]
        end if;
    end process;

    granted <= iGranted;

end behavioral;

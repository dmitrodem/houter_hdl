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

entity SpaceWireRouterIPRoundArbiter7 is
    port (
        clock    : in  std_logic;
        reset    : in  std_logic;
        occupied : in  std_logic;
        request0 : in  std_logic;
        request1 : in  std_logic;
        request2 : in  std_logic;
        request3 : in  std_logic;
        request4 : in  std_logic;
        request5 : in  std_logic;
        request6 : in  std_logic;
        granted  : out std_logic_vector (6 downto 0)
        );
end SpaceWireRouterIPRoundArbiter7;

architecture behavioral of SpaceWireRouterIPRoundArbiter7 is
    signal iGranted     : std_logic_vector (6 downto 0);
    signal iLastGranted : std_logic_vector (2 downto 0);
    signal iRequest0    : std_logic;
    signal iRequest1    : std_logic;
    signal iRequest2    : std_logic;
    signal iRequest3    : std_logic;
    signal iRequest4    : std_logic;
    signal iRequest5    : std_logic;
    signal iRequest6    : std_logic;
    signal ioccupied    : std_logic;
begin

    granted <= iGranted;


            iRequest0 <= request0;
            iRequest1 <= request1;
            iRequest2 <= request2;
            iRequest3 <= request3;
            iRequest4 <= request4;
            iRequest5 <= request5;
            iRequest6 <= request6;
            ioccupied <= occupied;


    process (clock, reset)
    begin
        if (reset = '1') then
            iGranted     <= (others => '0');
            iLastGranted <= "000";

        elsif (clock'event and clock = '1') then
            case iLastGranted is

                ----------------------------------------------------------------------
                -- The arbitration after Port0 is finished to access.
                ----------------------------------------------------------------------
                when "000" =>
                    if (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    end if;

                ----------------------------------------------------------------------
                -- The arbitration after Port1 is finished to access.
                ----------------------------------------------------------------------
                when "001" =>
                    if (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    end if;

                ----------------------------------------------------------------------
                -- The arbitration after Port2 is finished to access.
                ----------------------------------------------------------------------
                when "010" =>
                    if (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    end if;

                ----------------------------------------------------------------------
                -- The arbitration after Port3 is finished to access.
                ----------------------------------------------------------------------
                when "011" =>
                    if (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    end if;

                ----------------------------------------------------------------------
                -- The arbitration after Port4 is finished to access.
                ----------------------------------------------------------------------
                when "100" =>
                    if (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    end if;

                ----------------------------------------------------------------------
                -- The arbitration after Port5 is finished to access.
                ----------------------------------------------------------------------
                when "101" =>
                    if (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    end if;

                ----------------------------------------------------------------------
                -- The arbitration after Port6 is finished to access.
                ----------------------------------------------------------------------
                when others =>
                    if (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= "000";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= "001";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= "010";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= "011";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= "100";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= "101";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= "110";
                    end if;
            end case;

            if (irequest0 = '0' and iGranted (0) = '1') then iGranted (0) <= '0'; end if;
            if (irequest1 = '0' and iGranted (1) = '1') then iGranted (1) <= '0'; end if;
            if (irequest2 = '0' and iGranted (2) = '1') then iGranted (2) <= '0'; end if;
            if (irequest3 = '0' and iGranted (3) = '1') then iGranted (3) <= '0'; end if;
            if (irequest4 = '0' and iGranted (4) = '1') then iGranted (4) <= '0'; end if;
            if (irequest5 = '0' and iGranted (5) = '1') then iGranted (5) <= '0'; end if;
            if (irequest6 = '0' and iGranted (6) = '1') then iGranted (6) <= '0'; end if;

        end if;

    end process;

end behavioral;

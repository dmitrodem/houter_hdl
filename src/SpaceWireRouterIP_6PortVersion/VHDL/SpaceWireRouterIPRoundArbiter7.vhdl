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

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity SpaceWireRouterIPRoundArbiter7 is
    port (
        clock    : in  std_logic;
        reset    : in  std_logic;
        occupied : in  std_logic;
        -- [[[cog
        -- for i in range(0, n):
        --   print(f"request{i} : in  std_logic;")
        -- print(f"granted  : out std_logic_vector ({n-1} downto 0)")
        -- ]]]
        request0 : in  std_logic;
        request1 : in  std_logic;
        request2 : in  std_logic;
        request3 : in  std_logic;
        request4 : in  std_logic;
        request5 : in  std_logic;
        request6 : in  std_logic;
        granted  : out std_logic_vector (6 downto 0)
        -- [[[end]]]
        );
end SpaceWireRouterIPRoundArbiter7;

architecture behavioral of SpaceWireRouterIPRoundArbiter7 is
    -- [[[cog
    -- print(f"signal iGranted     : std_logic_vector ({n-1} downto 0);")
    -- print(f"signal iLastGranted : std_logic_vector (7 downto 0);")
    -- for i in range(0, n):
    --   print(f"signal iRequest{i}    : std_logic;")
    -- ]]]
    signal iGranted     : std_logic_vector (6 downto 0);
    signal iLastGranted : std_logic_vector (7 downto 0);
    signal iRequest0    : std_logic;
    signal iRequest1    : std_logic;
    signal iRequest2    : std_logic;
    signal iRequest3    : std_logic;
    signal iRequest4    : std_logic;
    signal iRequest5    : std_logic;
    signal iRequest6    : std_logic;
    -- [[[end]]]
    signal ioccupied    : std_logic;
begin

    granted <= iGranted;


    -- [[[cog
    -- for i in range(0, n):
    --   print(f"iRequest{i} <= request{i};")
    -- ]]]
    iRequest0 <= request0;
    iRequest1 <= request1;
    iRequest2 <= request2;
    iRequest3 <= request3;
    iRequest4 <= request4;
    iRequest5 <= request5;
    iRequest6 <= request6;
    -- [[[end]]]
    ioccupied <= occupied;


    process (clock, reset)
    begin
        if (reset = '1') then
            iGranted     <= (others => '0');
            iLastGranted <= x"00";

        elsif (clock'event and clock = '1') then
            case iLastGranted is
                -- [[[cog
                -- for i in range(0, n):
                --   v = "others" if (i == n-1) else f"x\"{i:02x}\""
                --   print(f"when {v} =>")
                --   for j in range(0, n):
                --     cmd = "if" if (j == 0) else "elsif"
                --     k = (i+1+j) % n
                --     mask = 1 << k
                --     print(f"    {cmd} (irequest{k} = '1' and ioccupied = '0') then")
                --     print(f"        iGranted <= \"{mask:0{n}b}\"; iLastGranted <= x\"{k:02x}\";")
                --   print(f"    end if;")
                -- ]]]
                when x"00" =>
                    if (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= x"01";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= x"02";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= x"03";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= x"04";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= x"05";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= x"06";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= x"00";
                    end if;
                when x"01" =>
                    if (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= x"02";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= x"03";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= x"04";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= x"05";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= x"06";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= x"00";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= x"01";
                    end if;
                when x"02" =>
                    if (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= x"03";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= x"04";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= x"05";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= x"06";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= x"00";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= x"01";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= x"02";
                    end if;
                when x"03" =>
                    if (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= x"04";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= x"05";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= x"06";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= x"00";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= x"01";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= x"02";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= x"03";
                    end if;
                when x"04" =>
                    if (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= x"05";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= x"06";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= x"00";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= x"01";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= x"02";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= x"03";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= x"04";
                    end if;
                when x"05" =>
                    if (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= x"06";
                    elsif (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= x"00";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= x"01";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= x"02";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= x"03";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= x"04";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= x"05";
                    end if;
                when others =>
                    if (irequest0 = '1' and ioccupied = '0') then
                        iGranted <= "0000001"; iLastGranted <= x"00";
                    elsif (irequest1 = '1' and ioccupied = '0') then
                        iGranted <= "0000010"; iLastGranted <= x"01";
                    elsif (irequest2 = '1' and ioccupied = '0') then
                        iGranted <= "0000100"; iLastGranted <= x"02";
                    elsif (irequest3 = '1' and ioccupied = '0') then
                        iGranted <= "0001000"; iLastGranted <= x"03";
                    elsif (irequest4 = '1' and ioccupied = '0') then
                        iGranted <= "0010000"; iLastGranted <= x"04";
                    elsif (irequest5 = '1' and ioccupied = '0') then
                        iGranted <= "0100000"; iLastGranted <= x"05";
                    elsif (irequest6 = '1' and ioccupied = '0') then
                        iGranted <= "1000000"; iLastGranted <= x"06";
                    end if;
                -- [[[end]]]
            end case;

            -- [[[cog
            -- for i in range(0, n):
            --   print(f"if (irequest{i} = '0' and iGranted ({i}) = '1') then iGranted ({i}) <= '0'; end if;")
            -- ]]]
            if (irequest0 = '0' and iGranted (0) = '1') then iGranted (0) <= '0'; end if;
            if (irequest1 = '0' and iGranted (1) = '1') then iGranted (1) <= '0'; end if;
            if (irequest2 = '0' and iGranted (2) = '1') then iGranted (2) <= '0'; end if;
            if (irequest3 = '0' and iGranted (3) = '1') then iGranted (3) <= '0'; end if;
            if (irequest4 = '0' and iGranted (4) = '1') then iGranted (4) <= '0'; end if;
            if (irequest5 = '0' and iGranted (5) = '1') then iGranted (5) <= '0'; end if;
            if (irequest6 = '0' and iGranted (6) = '1') then iGranted (6) <= '0'; end if;
            -- [[[end]]]
        end if;

    end process;

end behavioral;

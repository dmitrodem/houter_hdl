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

package SpaceWireRouterIPPackage is

    -- [[[cog
    -- print(f"constant cNumberOfInternalPort             : integer range 0 to 31          := {n};")
    -- print(f"constant cNumberOfExternalPort             : std_logic_vector (7 downto 0)  := x\"{n-1:02x}\";   -- port 0 to {n-1}.")
    -- ]]]
    constant cNumberOfInternalPort             : integer range 0 to 31          := 7;
    constant cNumberOfExternalPort             : std_logic_vector (7 downto 0)  := x"06";   -- port 0 to 6.
    -- [[[end]]]

    constant cRunStateTransmitClockDivideValue : std_logic_vector (5 downto 0)  := "000000";  -- transmitClock frequency / (cRunStateTransmitClockDivideValue + 1) = TransmitRate.
    -- [[[cog
    -- v = "1" * 31 + "0"
    -- print(f"constant cTransmitTimeCodeEnable           : std_logic_vector (31 downto 0)  := \"{v}\";  -- enable time-code forwarding.")
    -- ]]]
    constant cTransmitTimeCodeEnable           : std_logic_vector (31 downto 0)  := "11111111111111111111111111111110";  -- enable time-code forwarding.
    -- [[[end]]]
    constant cRMAPCRCRevision                  : std_logic                      := '1';        -- (0:Rev.e, 1:Rev.f).
    constant cWatchdogTimerEnable              : std_logic                      := '0';        -- enable port occupetion timeout.
    constant cUseDevice                        : integer range 0 to 1           := 1;          -- 1 = Xilinx, 0 = Altera
    constant cPortBit                          : std_logic_vector (31 downto 0) := x"0000007F";
--
    -- [[[cog
    -- print(f"function select{n}x1 (")
    -- print(f"    selectBit : std_logic_vector ({n-1} downto 0);")
    -- v = ", ".join([f"select{i}" for i in range(0, n)])
    -- print(f"    {v} : std_logic")
    -- print(f"    ) return std_logic;")
    -- print(f"function select{n}x1xVector8 (")
    -- print(f"    selectVector : std_logic_vector ({n-1} downto 0);")
    -- v = ", ".join([f"select{i}" for i in range(0, n)])
    -- print(f"    {v} : std_logic_vector (7 downto 0)")
    -- print(f"    ) return std_logic_vector;")
    -- print(f"function select{n}x1xVector9 (")
    -- print(f"    selectVector : std_logic_vector ({n-1} downto 0);")
    -- v = ", ".join([f"select{i}" for i in range(0, n)])
    -- print(f"    {v} : std_logic_vector (8 downto 0)")
    -- print(f"    ) return std_logic_vector;")
    -- ]]]
    function select7x1 (
        selectBit : std_logic_vector (6 downto 0);
        select0, select1, select2, select3, select4, select5, select6 : std_logic
        ) return std_logic;
    function select7x1xVector8 (
        selectVector : std_logic_vector (6 downto 0);
        select0, select1, select2, select3, select4, select5, select6 : std_logic_vector (7 downto 0)
        ) return std_logic_vector;
    function select7x1xVector9 (
        selectVector : std_logic_vector (6 downto 0);
        select0, select1, select2, select3, select4, select5, select6 : std_logic_vector (8 downto 0)
        ) return std_logic_vector;
    -- [[[end]]]

end SpaceWireRouterIPPackage;

package body SpaceWireRouterIPPackage is

    -- [[[cog
    -- print(f"function select{n}x1 (")
    -- print(f"    selectBit : std_logic_vector ({n-1} downto 0);")
    -- v = ", ".join([f"select{i}" for i in range(0, n)])
    -- print(f"    {v} : std_logic) return std_logic is")
    -- print(f"begin")
    -- v = " or ".join([f"(selectBit ({i}) and select{i})" for i in range(0, n)])
    -- print(f"    return ({v});")
    -- print(f"end select{n}x1;")
    -- ]]]
    function select7x1 (
        selectBit : std_logic_vector (6 downto 0);
        select0, select1, select2, select3, select4, select5, select6 : std_logic) return std_logic is
    begin
        return ((selectBit (0) and select0) or (selectBit (1) and select1) or (selectBit (2) and select2) or (selectBit (3) and select3) or (selectBit (4) and select4) or (selectBit (5) and select5) or (selectBit (6) and select6));
    end select7x1;
    -- [[[end]]]

    -- [[[cog
    -- print(f"function select{n}x1xVector8 (")
    -- print(f"    selectVector : std_logic_vector ({n-1} downto 0);")
    -- v = ", ".join([f"select{i}" for i in range(0, n)])
    -- print(f"    {v} : std_logic_vector (7 downto 0)) return std_logic_vector is")
    -- print(f"begin")
    -- for i in range(0, n):
    --   cmd = "if" if (i == 0) else "elsif"
    --   mask = 1 << i
    --   print(f"    {cmd} (selectVector = \"{mask:0{n}b}\") then return select{i};")
    -- print(f"    else return \"00000000\";")
    -- print(f"    end if;")
    -- print(f"end select{n}x1xVector8;")
    -- ]]]
    function select7x1xVector8 (
        selectVector : std_logic_vector (6 downto 0);
        select0, select1, select2, select3, select4, select5, select6 : std_logic_vector (7 downto 0)) return std_logic_vector is
    begin
        if (selectVector = "0000001") then return select0;
        elsif (selectVector = "0000010") then return select1;
        elsif (selectVector = "0000100") then return select2;
        elsif (selectVector = "0001000") then return select3;
        elsif (selectVector = "0010000") then return select4;
        elsif (selectVector = "0100000") then return select5;
        elsif (selectVector = "1000000") then return select6;
        else return "00000000";
        end if;
    end select7x1xVector8;
    -- [[[end]]]

    -- [[[cog
    -- print(f"function select{n}x1xVector9 (")
    -- print(f"    selectVector : std_logic_vector ({n-1} downto 0);")
    -- v = ", ".join([f"select{i}" for i in range(0, n)])
    -- print(f"    {v} : std_logic_vector (8 downto 0)) return std_logic_vector is")
    -- print(f"begin")
    -- for i in range(0, n):
    --   cmd = "if" if (i == 0) else "elsif"
    --   mask = 1 << i
    --   print(f"    {cmd} (selectVector = \"{mask:0{n}b}\") then return select{i};")
    -- print(f"    else return \"000000000\";")
    -- print(f"    end if;")
    -- print(f"end select{n}x1xVector9;")
    -- ]]]
    function select7x1xVector9 (
        selectVector : std_logic_vector (6 downto 0);
        select0, select1, select2, select3, select4, select5, select6 : std_logic_vector (8 downto 0)) return std_logic_vector is
    begin
        if (selectVector = "0000001") then return select0;
        elsif (selectVector = "0000010") then return select1;
        elsif (selectVector = "0000100") then return select2;
        elsif (selectVector = "0001000") then return select3;
        elsif (selectVector = "0010000") then return select4;
        elsif (selectVector = "0100000") then return select5;
        elsif (selectVector = "1000000") then return select6;
        else return "000000000";
        end if;
    end select7x1xVector9;
    -- [[[end]]]

end SpaceWireRouterIPPackage;

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
use ieee.numeric_std.all;

entity SpaceWireRouterIPTimeCodeControl6 is
    port(
        clock                 : in  std_logic;
        reset                 : in  std_logic;
        -- switch info.
        -- [[[cog
        -- print(f"linkUp                : in  std_logic_vector({n-1} downto 0);")
        -- ]]]
        linkUp                : in  std_logic_vector(6 downto 0);
        -- [[[end]]]
        receiveTimeCode       : out std_logic_vector(7 downto 0);
        -- spacewire timecode.
        -- [[[cog
        -- tmpl = """
        -- port{i}TimeCodeEnable   : in  std_logic;
        -- port{i}TickIn           : out std_logic;
        -- port{i}TimeCodeIn       : out std_logic_vector(7 downto 0);
        -- port{i}TickOut          : in  std_logic;
        -- port{i}TimeCodeOut      : in  std_logic_vector(7 downto 0);
        -- """.strip()
        -- for i in range(1, n):
        --   print(tmpl.format(i = i))
        -- ]]]
        port1TimeCodeEnable   : in  std_logic;
        port1TickIn           : out std_logic;
        port1TimeCodeIn       : out std_logic_vector(7 downto 0);
        port1TickOut          : in  std_logic;
        port1TimeCodeOut      : in  std_logic_vector(7 downto 0);
        port2TimeCodeEnable   : in  std_logic;
        port2TickIn           : out std_logic;
        port2TimeCodeIn       : out std_logic_vector(7 downto 0);
        port2TickOut          : in  std_logic;
        port2TimeCodeOut      : in  std_logic_vector(7 downto 0);
        port3TimeCodeEnable   : in  std_logic;
        port3TickIn           : out std_logic;
        port3TimeCodeIn       : out std_logic_vector(7 downto 0);
        port3TickOut          : in  std_logic;
        port3TimeCodeOut      : in  std_logic_vector(7 downto 0);
        port4TimeCodeEnable   : in  std_logic;
        port4TickIn           : out std_logic;
        port4TimeCodeIn       : out std_logic_vector(7 downto 0);
        port4TickOut          : in  std_logic;
        port4TimeCodeOut      : in  std_logic_vector(7 downto 0);
        port5TimeCodeEnable   : in  std_logic;
        port5TickIn           : out std_logic;
        port5TimeCodeIn       : out std_logic_vector(7 downto 0);
        port5TickOut          : in  std_logic;
        port5TimeCodeOut      : in  std_logic_vector(7 downto 0);
        port6TimeCodeEnable   : in  std_logic;
        port6TickIn           : out std_logic;
        port6TimeCodeIn       : out std_logic_vector(7 downto 0);
        port6TickOut          : in  std_logic;
        port6TimeCodeOut      : in  std_logic_vector(7 downto 0);
        -- [[[end]]]

        autoTimeCodeValue     : out std_logic_vector(7 downto 0);
        autoTimeCodeCycleTime : in  std_logic_vector(31 downto 0)
    );
end SpaceWireRouterIPTimeCodeControl6;

architecture behavioral of SpaceWireRouterIPTimeCodeControl6 is

    constant cInitializeTimeCode     : std_logic_vector(5 downto 0) := "000000";
    --
    signal iTimeCodeOut              : std_logic_vector(5 downto 0);
    signal iTimeCodeOutPlus1         : std_logic_vector(5 downto 0);
    signal iReceiveControlFlags      : std_logic_vector(1 downto 0);
    -- [[[cog
    -- print(f"signal iTickOut                  : std_logic_vector({n-2} downto 0);")
    -- ]]]
    signal iTickOut                  : std_logic_vector(5 downto 0);
    -- [[[end]]]
    --
    signal iReceiveTimeCode          : std_logic_vector(7 downto 0);
    --
    -- [[[cog
    -- for i in range(1, n):
    --   print(f"signal iPort{i}TickIn              : std_logic;")
    -- for i in range(1, n):
    --   print(f"signal iPort{i}TimeCodeIn          : std_logic_vector(7 downto 0);")
    -- ]]]
    signal iPort1TickIn              : std_logic;
    signal iPort2TickIn              : std_logic;
    signal iPort3TickIn              : std_logic;
    signal iPort4TickIn              : std_logic;
    signal iPort5TickIn              : std_logic;
    signal iPort6TickIn              : std_logic;
    signal iPort1TimeCodeIn          : std_logic_vector(7 downto 0);
    signal iPort2TimeCodeIn          : std_logic_vector(7 downto 0);
    signal iPort3TimeCodeIn          : std_logic_vector(7 downto 0);
    signal iPort4TimeCodeIn          : std_logic_vector(7 downto 0);
    signal iPort5TimeCodeIn          : std_logic_vector(7 downto 0);
    signal iPort6TimeCodeIn          : std_logic_vector(7 downto 0);
    -- [[[end]]]
    signal iCycleCounter             : unsigned(31 downto 0);
    signal iAutoTickIn               : std_logic;
    signal iAutoTimeCodeIn           : std_logic_vector(5 downto 0);

begin

    receiveTimeCode <= iReceiveTimeCode;

    -- [[[cog
    -- for i in range(1, n):
    --   print(f"port{i}TickIn <= iPort{i}TickIn;")
    -- for i in range(1, n):
    --   print(f"port{i}TimeCodeIn <= iPort{i}TimeCodeIn;")
    -- ]]]
    port1TickIn <= iPort1TickIn;
    port2TickIn <= iPort2TickIn;
    port3TickIn <= iPort3TickIn;
    port4TickIn <= iPort4TickIn;
    port5TickIn <= iPort5TickIn;
    port6TickIn <= iPort6TickIn;
    port1TimeCodeIn <= iPort1TimeCodeIn;
    port2TimeCodeIn <= iPort2TimeCodeIn;
    port3TimeCodeIn <= iPort3TimeCodeIn;
    port4TimeCodeIn <= iPort4TimeCodeIn;
    port5TimeCodeIn <= iPort5TimeCodeIn;
    port6TimeCodeIn <= iPort6TimeCodeIn;
    -- [[[end]]]

    -- [[[cog
    -- for i in range(1, n):
    --   print(f"iPort{i}TickIn     <= iTickOut({i-1}) when (port{i}TimeCodeEnable = '1' and linkUp({i}) = '1') else '0';")
    --   print(f"iPort{i}TimeCodeIn <= iReceiveControlFlags & iTimeCodeOut when (autoTimeCodeCycleTime = x\"00000000\") else \"00\" & iAutoTimeCodeIn;")
    -- ]]]
    iPort1TickIn     <= iTickOut(0) when (port1TimeCodeEnable = '1' and linkUp(1) = '1') else '0';
    iPort1TimeCodeIn <= iReceiveControlFlags & iTimeCodeOut when (autoTimeCodeCycleTime = x"00000000") else "00" & iAutoTimeCodeIn;
    iPort2TickIn     <= iTickOut(1) when (port2TimeCodeEnable = '1' and linkUp(2) = '1') else '0';
    iPort2TimeCodeIn <= iReceiveControlFlags & iTimeCodeOut when (autoTimeCodeCycleTime = x"00000000") else "00" & iAutoTimeCodeIn;
    iPort3TickIn     <= iTickOut(2) when (port3TimeCodeEnable = '1' and linkUp(3) = '1') else '0';
    iPort3TimeCodeIn <= iReceiveControlFlags & iTimeCodeOut when (autoTimeCodeCycleTime = x"00000000") else "00" & iAutoTimeCodeIn;
    iPort4TickIn     <= iTickOut(3) when (port4TimeCodeEnable = '1' and linkUp(4) = '1') else '0';
    iPort4TimeCodeIn <= iReceiveControlFlags & iTimeCodeOut when (autoTimeCodeCycleTime = x"00000000") else "00" & iAutoTimeCodeIn;
    iPort5TickIn     <= iTickOut(4) when (port5TimeCodeEnable = '1' and linkUp(5) = '1') else '0';
    iPort5TimeCodeIn <= iReceiveControlFlags & iTimeCodeOut when (autoTimeCodeCycleTime = x"00000000") else "00" & iAutoTimeCodeIn;
    iPort6TickIn     <= iTickOut(5) when (port6TimeCodeEnable = '1' and linkUp(6) = '1') else '0';
    iPort6TimeCodeIn <= iReceiveControlFlags & iTimeCodeOut when (autoTimeCodeCycleTime = x"00000000") else "00" & iAutoTimeCodeIn;
    -- [[[end]]]

    iReceiveTimeCode <= iReceiveControlFlags & iTimeCodeOut;

    ----------------------------------------------------------------------
    -- ECSS-E-ST-50-12C 8.12 System time distribution (normative)
    -- ECSS-E-ST-50-12C 7.3 Control characters and control codes
    -- TimeCode Host
    -- Occur TimeCode and tick signal which is asserted periodically set value
    -- in AutoTimeCodeValueRegister.
    -- This TimeCode,tick signal is sending to all output ports of the router.
    -- TimeCode Target
    -- Check The new time is one more than the time-counter's previous time-value.
    -- If the Time-Code is valid, send Tick signal.
    -- The TimeCode send out from all port.
    ----------------------------------------------------------------------
    process(clock, reset)
    begin
        if (reset = '1') then
            iTimeCodeOut         <= cInitializeTimeCode;
            iTimeCodeOutPlus1    <= std_logic_vector(unsigned(cInitializeTimeCode) + 1);
            iReceiveControlFlags <= "00";
            iTickOut             <= (others => '0');

        elsif (clock'event and clock = '1') then
            ----------------------------------------------------------------------
            -- TimeCode Host.
            ----------------------------------------------------------------------
            if (autoTimeCodeCycleTime /= x"00000000") then
                if (iAutoTickIn = '1') then
                    iTickOut <= (others => '1');
                else
                    iTickOut <= (others => '0');
                end if;
            else
                ----------------------------------------------------------------------
                -- TimeCode Target
                -- Port1 TimeCode Receive.
                ----------------------------------------------------------------------
                -- [[[cog
                -- tmpl = """
                -- {s} (port{i}TickOut = '1') then
                --    if (port{i}TimeCodeOut(5 downto 0) = iTimeCodeOutPlus1) then
                --        iTickOut <= \"{tick_out:0{n1}b}\";
                --    end if;
                --    iTimeCodeOut         <= port{i}TimeCodeOut(5 downto 0);
                --    iTimeCodeOutPlus1    <= std_logic_vector(unsigned(port{i}TimeCodeOut(5 downto 0)) + 1);
                --    iReceiveControlFlags <= port{i}TimeCodeOut(7 downto 6);
                -- """.strip()
                -- for i in range(1, n):
                --   k = (1 << (n-1)) - 1
                --   tick_out = k ^ (1 << (i-1))
                --   print(tmpl.format(i = i, n1 = n-1, tick_out = tick_out, s = 'if' if i == 1 else 'elsif'))
                -- ]]]
                if (port1TickOut = '1') then
                   if (port1TimeCodeOut(5 downto 0) = iTimeCodeOutPlus1) then
                       iTickOut <= "111110";
                   end if;
                   iTimeCodeOut         <= port1TimeCodeOut(5 downto 0);
                   iTimeCodeOutPlus1    <= std_logic_vector(unsigned(port1TimeCodeOut(5 downto 0)) + 1);
                   iReceiveControlFlags <= port1TimeCodeOut(7 downto 6);
                elsif (port2TickOut = '1') then
                   if (port2TimeCodeOut(5 downto 0) = iTimeCodeOutPlus1) then
                       iTickOut <= "111101";
                   end if;
                   iTimeCodeOut         <= port2TimeCodeOut(5 downto 0);
                   iTimeCodeOutPlus1    <= std_logic_vector(unsigned(port2TimeCodeOut(5 downto 0)) + 1);
                   iReceiveControlFlags <= port2TimeCodeOut(7 downto 6);
                elsif (port3TickOut = '1') then
                   if (port3TimeCodeOut(5 downto 0) = iTimeCodeOutPlus1) then
                       iTickOut <= "111011";
                   end if;
                   iTimeCodeOut         <= port3TimeCodeOut(5 downto 0);
                   iTimeCodeOutPlus1    <= std_logic_vector(unsigned(port3TimeCodeOut(5 downto 0)) + 1);
                   iReceiveControlFlags <= port3TimeCodeOut(7 downto 6);
                elsif (port4TickOut = '1') then
                   if (port4TimeCodeOut(5 downto 0) = iTimeCodeOutPlus1) then
                       iTickOut <= "110111";
                   end if;
                   iTimeCodeOut         <= port4TimeCodeOut(5 downto 0);
                   iTimeCodeOutPlus1    <= std_logic_vector(unsigned(port4TimeCodeOut(5 downto 0)) + 1);
                   iReceiveControlFlags <= port4TimeCodeOut(7 downto 6);
                elsif (port5TickOut = '1') then
                   if (port5TimeCodeOut(5 downto 0) = iTimeCodeOutPlus1) then
                       iTickOut <= "101111";
                   end if;
                   iTimeCodeOut         <= port5TimeCodeOut(5 downto 0);
                   iTimeCodeOutPlus1    <= std_logic_vector(unsigned(port5TimeCodeOut(5 downto 0)) + 1);
                   iReceiveControlFlags <= port5TimeCodeOut(7 downto 6);
                elsif (port6TickOut = '1') then
                   if (port6TimeCodeOut(5 downto 0) = iTimeCodeOutPlus1) then
                       iTickOut <= "011111";
                   end if;
                   iTimeCodeOut         <= port6TimeCodeOut(5 downto 0);
                   iTimeCodeOutPlus1    <= std_logic_vector(unsigned(port6TimeCodeOut(5 downto 0)) + 1);
                   iReceiveControlFlags <= port6TimeCodeOut(7 downto 6);
                -- [[[end]]]
                else
                    iTickOut <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    autoTimeCodeValue <= "00" & std_logic_vector(iAutoTimeCodeIn);

    ----------------------------------------------------------------------
    -- TimeCode Host.
    -- Send TimeCode periodically in set value.
    ----------------------------------------------------------------------
    process(clock, reset)
    begin
        if (reset = '1') then
            iAutoTimeCodeIn <= (others => '0');
            iCycleCounter   <= (others => '0');
            iAutoTickIn     <= '0';

        elsif (clock'event and clock = '1') then
            if (autoTimeCodeCycleTime /= x"00000000") then

                if (iCycleCounter > unsigned(autoTimeCodeCycleTime)) then
                    iCycleCounter   <= (others => '0');
                    iAutoTickIn     <= '1';
                    iAutoTimeCodeIn <= std_logic_vector(unsigned(iAutoTimeCodeIn) + 1);
                else
                    iCycleCounter <= iCycleCounter + 1;
                    iAutoTickIn   <= '0';

                end if;
            else
                iAutoTickIn   <= '0';
                iCycleCounter <= (others => '0');
            end if;
        end if;
    end process;
    -------------------------------------------------------------

end behavioral;

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

------- switch --------
--
--      0 1 2 3 4 5 6
--    0 x - - - - - -
--    1 - x - - - - -
--    2 - - x - - - -
--    3 o - - x - - -
--    4 - - - - x - -
--    5 - - - - - x -
--    6 - - - - - - x
--  o : rx0=>tx3
--  x :loopback

entity SpaceWireRouterIPArbiter7x7 is
    port (
        clock              : in  std_logic;
        reset              : in  std_logic;
        -- [[[cog
        -- a = []; b = []; c = [];
        -- for i in range(0, n):
        --   a.append(f"destinationOfPort{i} : in  std_logic_vector (7 downto 0);")
        --   b.append(f"requestOfPort{i}     : in  std_logic;")
        --   c.append(f"grantedToPort{i}     : out std_logic;")
        -- msg = "\n".join(a + b + c)
        -- print(msg)
        -- msg = f"routingSwitch      : out std_logic_vector ({n**2-1} downto 0)"
        -- print(msg)
        -- ]]]
        destinationOfPort0 : in  std_logic_vector (7 downto 0);
        destinationOfPort1 : in  std_logic_vector (7 downto 0);
        destinationOfPort2 : in  std_logic_vector (7 downto 0);
        destinationOfPort3 : in  std_logic_vector (7 downto 0);
        destinationOfPort4 : in  std_logic_vector (7 downto 0);
        destinationOfPort5 : in  std_logic_vector (7 downto 0);
        destinationOfPort6 : in  std_logic_vector (7 downto 0);
        requestOfPort0     : in  std_logic;
        requestOfPort1     : in  std_logic;
        requestOfPort2     : in  std_logic;
        requestOfPort3     : in  std_logic;
        requestOfPort4     : in  std_logic;
        requestOfPort5     : in  std_logic;
        requestOfPort6     : in  std_logic;
        grantedToPort0     : out std_logic;
        grantedToPort1     : out std_logic;
        grantedToPort2     : out std_logic;
        grantedToPort3     : out std_logic;
        grantedToPort4     : out std_logic;
        grantedToPort5     : out std_logic;
        grantedToPort6     : out std_logic;
        routingSwitch      : out std_logic_vector (48 downto 0)
        -- [[[end]]]
        );
end SpaceWireRouterIPArbiter7x7;

architecture behavioral of SpaceWireRouterIPArbiter7x7 is

    -- [[[cog
    -- print(f"signal iRoutingSwitch    : std_logic_vector ({n**2-1} downto 0);")
    -- a = [f"signal iOccupiedPort{i}    : std_logic;" for i in range(0, n)]
    -- b = [f"signal iRequesterToPort{i} : std_logic_vector ({n-1} downto 0);" for i in range(0, n)]
    -- c = [f"signal iGrantedToPort{i}   : std_logic;" for i in range(0, n)]
    -- print("\n".join(a+b+c))
    -- ]]]
    signal iRoutingSwitch    : std_logic_vector (48 downto 0);
    signal iOccupiedPort0    : std_logic;
    signal iOccupiedPort1    : std_logic;
    signal iOccupiedPort2    : std_logic;
    signal iOccupiedPort3    : std_logic;
    signal iOccupiedPort4    : std_logic;
    signal iOccupiedPort5    : std_logic;
    signal iOccupiedPort6    : std_logic;
    signal iRequesterToPort0 : std_logic_vector (6 downto 0);
    signal iRequesterToPort1 : std_logic_vector (6 downto 0);
    signal iRequesterToPort2 : std_logic_vector (6 downto 0);
    signal iRequesterToPort3 : std_logic_vector (6 downto 0);
    signal iRequesterToPort4 : std_logic_vector (6 downto 0);
    signal iRequesterToPort5 : std_logic_vector (6 downto 0);
    signal iRequesterToPort6 : std_logic_vector (6 downto 0);
    signal iGrantedToPort0   : std_logic;
    signal iGrantedToPort1   : std_logic;
    signal iGrantedToPort2   : std_logic;
    signal iGrantedToPort3   : std_logic;
    signal iGrantedToPort4   : std_logic;
    signal iGrantedToPort5   : std_logic;
    signal iGrantedToPort6   : std_logic;
    -- [[[end]]]
begin

----------------------------------------------------------------------
-- ECSS-E-ST-50-12C 10.2.5 Arbitration
-- Two or more input ports can all be waiting to send data out of the same
-- output port: SpaceWire routing switches shall provide a means of
-- arbitrating between input ports requesting the same output port.
-- Packet based (EOP,EEP and TIMEOUT) arbitration schemes is implemented.
----------------------------------------------------------------------

    -- [[[cog
    -- a = [f"grantedToPort{i} <= iGrantedToPort{i};" for i in range(0, n)]
    -- print("\n".join(a))
    -- ]]]
    grantedToPort0 <= iGrantedToPort0;
    grantedToPort1 <= iGrantedToPort1;
    grantedToPort2 <= iGrantedToPort2;
    grantedToPort3 <= iGrantedToPort3;
    grantedToPort4 <= iGrantedToPort4;
    grantedToPort5 <= iGrantedToPort5;
    grantedToPort6 <= iGrantedToPort6;
    -- [[[end]]]

----------------------------------------------------------------------
-- Route occupation signal, the source Port number0 to 6 ,Destination Port.
----------------------------------------------------------------------
    -- [[[cog
    -- for i in range(0, n):
    --   a = " or ".join([f"iRoutingSwitch ({j + n*i})" for j in range(0, n)])
    --   msg = f"iOccupiedPort{i} <= {a};"
    --   print(msg)
    -- ]]]
    iOccupiedPort0 <= iRoutingSwitch (0) or iRoutingSwitch (1) or iRoutingSwitch (2) or iRoutingSwitch (3) or iRoutingSwitch (4) or iRoutingSwitch (5) or iRoutingSwitch (6);
    iOccupiedPort1 <= iRoutingSwitch (7) or iRoutingSwitch (8) or iRoutingSwitch (9) or iRoutingSwitch (10) or iRoutingSwitch (11) or iRoutingSwitch (12) or iRoutingSwitch (13);
    iOccupiedPort2 <= iRoutingSwitch (14) or iRoutingSwitch (15) or iRoutingSwitch (16) or iRoutingSwitch (17) or iRoutingSwitch (18) or iRoutingSwitch (19) or iRoutingSwitch (20);
    iOccupiedPort3 <= iRoutingSwitch (21) or iRoutingSwitch (22) or iRoutingSwitch (23) or iRoutingSwitch (24) or iRoutingSwitch (25) or iRoutingSwitch (26) or iRoutingSwitch (27);
    iOccupiedPort4 <= iRoutingSwitch (28) or iRoutingSwitch (29) or iRoutingSwitch (30) or iRoutingSwitch (31) or iRoutingSwitch (32) or iRoutingSwitch (33) or iRoutingSwitch (34);
    iOccupiedPort5 <= iRoutingSwitch (35) or iRoutingSwitch (36) or iRoutingSwitch (37) or iRoutingSwitch (38) or iRoutingSwitch (39) or iRoutingSwitch (40) or iRoutingSwitch (41);
    iOccupiedPort6 <= iRoutingSwitch (42) or iRoutingSwitch (43) or iRoutingSwitch (44) or iRoutingSwitch (45) or iRoutingSwitch (46) or iRoutingSwitch (47) or iRoutingSwitch (48);
    -- [[[end]]]

----------------------------------------------------------------------
-- Source port number which request port as the destination port.
----------------------------------------------------------------------
    -- [[[cog
    -- for i in range(0, n):
    --   for j in range(0, n):
    --     print(f"iRequesterToPort{j} ({i}) <= '1' when requestOfPort{i} = '1' and destinationOfPort{i} = x\"{j:02x}\" else '0';")
    -- ]]]
    iRequesterToPort0 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"00" else '0';
    iRequesterToPort1 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"01" else '0';
    iRequesterToPort2 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"02" else '0';
    iRequesterToPort3 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"03" else '0';
    iRequesterToPort4 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"04" else '0';
    iRequesterToPort5 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"05" else '0';
    iRequesterToPort6 (0) <= '1' when requestOfPort0 = '1' and destinationOfPort0 = x"06" else '0';
    iRequesterToPort0 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"00" else '0';
    iRequesterToPort1 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"01" else '0';
    iRequesterToPort2 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"02" else '0';
    iRequesterToPort3 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"03" else '0';
    iRequesterToPort4 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"04" else '0';
    iRequesterToPort5 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"05" else '0';
    iRequesterToPort6 (1) <= '1' when requestOfPort1 = '1' and destinationOfPort1 = x"06" else '0';
    iRequesterToPort0 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"00" else '0';
    iRequesterToPort1 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"01" else '0';
    iRequesterToPort2 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"02" else '0';
    iRequesterToPort3 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"03" else '0';
    iRequesterToPort4 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"04" else '0';
    iRequesterToPort5 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"05" else '0';
    iRequesterToPort6 (2) <= '1' when requestOfPort2 = '1' and destinationOfPort2 = x"06" else '0';
    iRequesterToPort0 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"00" else '0';
    iRequesterToPort1 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"01" else '0';
    iRequesterToPort2 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"02" else '0';
    iRequesterToPort3 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"03" else '0';
    iRequesterToPort4 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"04" else '0';
    iRequesterToPort5 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"05" else '0';
    iRequesterToPort6 (3) <= '1' when requestOfPort3 = '1' and destinationOfPort3 = x"06" else '0';
    iRequesterToPort0 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"00" else '0';
    iRequesterToPort1 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"01" else '0';
    iRequesterToPort2 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"02" else '0';
    iRequesterToPort3 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"03" else '0';
    iRequesterToPort4 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"04" else '0';
    iRequesterToPort5 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"05" else '0';
    iRequesterToPort6 (4) <= '1' when requestOfPort4 = '1' and destinationOfPort4 = x"06" else '0';
    iRequesterToPort0 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"00" else '0';
    iRequesterToPort1 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"01" else '0';
    iRequesterToPort2 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"02" else '0';
    iRequesterToPort3 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"03" else '0';
    iRequesterToPort4 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"04" else '0';
    iRequesterToPort5 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"05" else '0';
    iRequesterToPort6 (5) <= '1' when requestOfPort5 = '1' and destinationOfPort5 = x"06" else '0';
    iRequesterToPort0 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"00" else '0';
    iRequesterToPort1 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"01" else '0';
    iRequesterToPort2 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"02" else '0';
    iRequesterToPort3 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"03" else '0';
    iRequesterToPort4 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"04" else '0';
    iRequesterToPort5 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"05" else '0';
    iRequesterToPort6 (6) <= '1' when requestOfPort6 = '1' and destinationOfPort6 = x"06" else '0';
    -- [[[end]]]

    -- [[[cog
    -- for i in range(0, n):
    --   print(f"arbiter{i:02} : entity work.SpaceWireRouterIPRoundArbiter7 port map (")
    --   print(f"    clock    => clock,")
    --   print(f"    reset    => reset,")
    --   print(f"    occupied => iOccupiedPort{i},")
    --   for j in range(0, n):
    --     print(f"    request{j} => iRequesterToPort{i} ({j}),")
    --   print(f"    granted  => iRoutingSwitch ({n-1 + i*n} downto {i*n})")
    --   print(f"    );")
    -- ]]]
    arbiter00 : entity work.SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort0,
        request0 => iRequesterToPort0 (0),
        request1 => iRequesterToPort0 (1),
        request2 => iRequesterToPort0 (2),
        request3 => iRequesterToPort0 (3),
        request4 => iRequesterToPort0 (4),
        request5 => iRequesterToPort0 (5),
        request6 => iRequesterToPort0 (6),
        granted  => iRoutingSwitch (6 downto 0)
        );
    arbiter01 : entity work.SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort1,
        request0 => iRequesterToPort1 (0),
        request1 => iRequesterToPort1 (1),
        request2 => iRequesterToPort1 (2),
        request3 => iRequesterToPort1 (3),
        request4 => iRequesterToPort1 (4),
        request5 => iRequesterToPort1 (5),
        request6 => iRequesterToPort1 (6),
        granted  => iRoutingSwitch (13 downto 7)
        );
    arbiter02 : entity work.SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort2,
        request0 => iRequesterToPort2 (0),
        request1 => iRequesterToPort2 (1),
        request2 => iRequesterToPort2 (2),
        request3 => iRequesterToPort2 (3),
        request4 => iRequesterToPort2 (4),
        request5 => iRequesterToPort2 (5),
        request6 => iRequesterToPort2 (6),
        granted  => iRoutingSwitch (20 downto 14)
        );
    arbiter03 : entity work.SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort3,
        request0 => iRequesterToPort3 (0),
        request1 => iRequesterToPort3 (1),
        request2 => iRequesterToPort3 (2),
        request3 => iRequesterToPort3 (3),
        request4 => iRequesterToPort3 (4),
        request5 => iRequesterToPort3 (5),
        request6 => iRequesterToPort3 (6),
        granted  => iRoutingSwitch (27 downto 21)
        );
    arbiter04 : entity work.SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort4,
        request0 => iRequesterToPort4 (0),
        request1 => iRequesterToPort4 (1),
        request2 => iRequesterToPort4 (2),
        request3 => iRequesterToPort4 (3),
        request4 => iRequesterToPort4 (4),
        request5 => iRequesterToPort4 (5),
        request6 => iRequesterToPort4 (6),
        granted  => iRoutingSwitch (34 downto 28)
        );
    arbiter05 : entity work.SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort5,
        request0 => iRequesterToPort5 (0),
        request1 => iRequesterToPort5 (1),
        request2 => iRequesterToPort5 (2),
        request3 => iRequesterToPort5 (3),
        request4 => iRequesterToPort5 (4),
        request5 => iRequesterToPort5 (5),
        request6 => iRequesterToPort5 (6),
        granted  => iRoutingSwitch (41 downto 35)
        );
    arbiter06 : entity work.SpaceWireRouterIPRoundArbiter7 port map (
        clock    => clock,
        reset    => reset,
        occupied => iOccupiedPort6,
        request0 => iRequesterToPort6 (0),
        request1 => iRequesterToPort6 (1),
        request2 => iRequesterToPort6 (2),
        request3 => iRequesterToPort6 (3),
        request4 => iRequesterToPort6 (4),
        request5 => iRequesterToPort6 (5),
        request6 => iRequesterToPort6 (6),
        granted  => iRoutingSwitch (48 downto 42)
        );
    -- [[[end]]]

----------------------------------------------------------------------
-- Connection enable signal, the source Port,  Destination Port number0 to 6.
----------------------------------------------------------------------
    -- [[[cog
    -- for i in range(0, n):
    --   a = " or ".join([f"iRoutingSwitch ({i+j*n})" for j in range(0, n)])
    --   print(f"iGrantedToPort{i} <= {a};")
    -- ]]]
    iGrantedToPort0 <= iRoutingSwitch (0) or iRoutingSwitch (7) or iRoutingSwitch (14) or iRoutingSwitch (21) or iRoutingSwitch (28) or iRoutingSwitch (35) or iRoutingSwitch (42);
    iGrantedToPort1 <= iRoutingSwitch (1) or iRoutingSwitch (8) or iRoutingSwitch (15) or iRoutingSwitch (22) or iRoutingSwitch (29) or iRoutingSwitch (36) or iRoutingSwitch (43);
    iGrantedToPort2 <= iRoutingSwitch (2) or iRoutingSwitch (9) or iRoutingSwitch (16) or iRoutingSwitch (23) or iRoutingSwitch (30) or iRoutingSwitch (37) or iRoutingSwitch (44);
    iGrantedToPort3 <= iRoutingSwitch (3) or iRoutingSwitch (10) or iRoutingSwitch (17) or iRoutingSwitch (24) or iRoutingSwitch (31) or iRoutingSwitch (38) or iRoutingSwitch (45);
    iGrantedToPort4 <= iRoutingSwitch (4) or iRoutingSwitch (11) or iRoutingSwitch (18) or iRoutingSwitch (25) or iRoutingSwitch (32) or iRoutingSwitch (39) or iRoutingSwitch (46);
    iGrantedToPort5 <= iRoutingSwitch (5) or iRoutingSwitch (12) or iRoutingSwitch (19) or iRoutingSwitch (26) or iRoutingSwitch (33) or iRoutingSwitch (40) or iRoutingSwitch (47);
    iGrantedToPort6 <= iRoutingSwitch (6) or iRoutingSwitch (13) or iRoutingSwitch (20) or iRoutingSwitch (27) or iRoutingSwitch (34) or iRoutingSwitch (41) or iRoutingSwitch (48);
    -- [[[end]]]

    routingSwitch <= iRoutingSwitch;

end behavioral;

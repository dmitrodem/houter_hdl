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
use work.SpaceWireRouterIPPackage.all;
use work.SpaceWireCODECIPPackage.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SpaceWireRouterIP is
    generic (
        gNumberOfInternalPort : integer := cNumberOfInternalPort
        );
    port (
        clock                       : in  std_logic;
        transmitClock               : in  std_logic;
        receiveClock                : in  std_logic;
        reset                       : in  std_logic;
        -- SpaceWire Signals.
        -- [[[cog
        -- for i in range(1, int(nports)+1):
        --   print(f"-- Port{i}.")
        --   print(f"spaceWireDataIn{i}            : in  std_logic;")
        --   print(f"spaceWireStrobeIn{i}          : in  std_logic;")
        --   print(f"spaceWireDataOut{i}           : out std_logic;")
        --   print(f"spaceWireStrobeOut{i}         : out std_logic;")
        -- ]]]
        -- Port1.
        spaceWireDataIn1            : in  std_logic;
        spaceWireStrobeIn1          : in  std_logic;
        spaceWireDataOut1           : out std_logic;
        spaceWireStrobeOut1         : out std_logic;
        -- Port2.
        spaceWireDataIn2            : in  std_logic;
        spaceWireStrobeIn2          : in  std_logic;
        spaceWireDataOut2           : out std_logic;
        spaceWireStrobeOut2         : out std_logic;
        -- Port3.
        spaceWireDataIn3            : in  std_logic;
        spaceWireStrobeIn3          : in  std_logic;
        spaceWireDataOut3           : out std_logic;
        spaceWireStrobeOut3         : out std_logic;
        -- Port4.
        spaceWireDataIn4            : in  std_logic;
        spaceWireStrobeIn4          : in  std_logic;
        spaceWireDataOut4           : out std_logic;
        spaceWireStrobeOut4         : out std_logic;
        -- Port5.
        spaceWireDataIn5            : in  std_logic;
        spaceWireStrobeIn5          : in  std_logic;
        spaceWireDataOut5           : out std_logic;
        spaceWireStrobeOut5         : out std_logic;
        -- Port6.
        spaceWireDataIn6            : in  std_logic;
        spaceWireStrobeIn6          : in  std_logic;
        spaceWireDataOut6           : out std_logic;
        spaceWireStrobeOut6         : out std_logic;
        -- [[[end]]]
        --
        -- [[[cog
        -- for i in range(1, int(nports)+1):
        --   print(f"statisticalInformationPort{i} : out bit32X8Array;")
        -- ]]]
        statisticalInformationPort1 : out bit32X8Array;
        statisticalInformationPort2 : out bit32X8Array;
        statisticalInformationPort3 : out bit32X8Array;
        statisticalInformationPort4 : out bit32X8Array;
        statisticalInformationPort5 : out bit32X8Array;
        statisticalInformationPort6 : out bit32X8Array;
        -- [[[end]]]
        --
        -- [[[cog
        -- for i in range(1, int(nports)+1):
        --   print(f"oneShotStatusPort{i}          : out std_logic_vector(7 downto 0);")
        -- ]]]
        oneShotStatusPort1          : out std_logic_vector(7 downto 0);
        oneShotStatusPort2          : out std_logic_vector(7 downto 0);
        oneShotStatusPort3          : out std_logic_vector(7 downto 0);
        oneShotStatusPort4          : out std_logic_vector(7 downto 0);
        oneShotStatusPort5          : out std_logic_vector(7 downto 0);
        oneShotStatusPort6          : out std_logic_vector(7 downto 0);
        -- [[[end]]]

        busMasterUserAddressIn      : in  std_logic_vector (31 downto 0);
        busMasterUserDataOut        : out std_logic_vector (31 downto 0);
        busMasterUserDataIn         : in  std_logic_vector (31 downto 0);
        busMasterUserWriteEnableIn  : in  std_logic;
        busMasterUserByteEnableIn   : in  std_logic_vector (3 downto 0);
        busMasterUserStrobeIn       : in  std_logic;
        busMasterUserRequestIn      : in  std_logic;
        busMasterUserAcknowledgeOut : out std_logic
        );
end SpaceWireRouterIP;


architecture behavioral of SpaceWireRouterIP is

    -- [[[cog
    -- a = []; b = []; c = []
    -- for i in range(0, int(nports)+1):
    --   a.append(f"signal packetDropped{i}   : std_logic;")
    --   b.append(f"signal timeOutCount{i}    : std_logic_vector (15 downto 0);")
    --   c.append(f"signal packetDropCount{i} : std_logic_vector (15 downto 0);")
    -- msg = "\n".join(a + b + c)
    -- print(msg)
    -- ]]]
    signal packetDropped0   : std_logic;
    signal packetDropped1   : std_logic;
    signal packetDropped2   : std_logic;
    signal packetDropped3   : std_logic;
    signal packetDropped4   : std_logic;
    signal packetDropped5   : std_logic;
    signal packetDropped6   : std_logic;
    signal timeOutCount0    : std_logic_vector (15 downto 0);
    signal timeOutCount1    : std_logic_vector (15 downto 0);
    signal timeOutCount2    : std_logic_vector (15 downto 0);
    signal timeOutCount3    : std_logic_vector (15 downto 0);
    signal timeOutCount4    : std_logic_vector (15 downto 0);
    signal timeOutCount5    : std_logic_vector (15 downto 0);
    signal timeOutCount6    : std_logic_vector (15 downto 0);
    signal packetDropCount0 : std_logic_vector (15 downto 0);
    signal packetDropCount1 : std_logic_vector (15 downto 0);
    signal packetDropCount2 : std_logic_vector (15 downto 0);
    signal packetDropCount3 : std_logic_vector (15 downto 0);
    signal packetDropCount4 : std_logic_vector (15 downto 0);
    signal packetDropCount5 : std_logic_vector (15 downto 0);
    signal packetDropCount6 : std_logic_vector (15 downto 0);
    -- [[[end]]]

    type portXPortArray is array (gNumberOfInternalPort - 1 downto 0) of std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    type bit8XPortArray is array (gNumberOfInternalPort - 1 downto 0) of std_logic_vector (7 downto 0);
    type bit9XPortArray is array (gNumberOfInternalPort - 1 downto 0) of std_logic_vector (8 downto 0);

    signal iSelectDestinationPort            : portXPortArray;
    signal iSwitchPortNumber                 : portXPortArray;
--
    signal requestOut                        : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal destinationPort                   : bit8XPortArray;
    signal sorcePortrOut                     : bit8XPortArray;
    signal granted                           : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal iReadyIn                          : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal dataOut                           : bit9XPortArray;
    signal strobeOut                         : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal iRequestIn                        : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal iSorcePortIn                      : bit8XPortArray;
    signal iDataIn                           : bit9XPortArray;
    signal iStrobeIn                         : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal readyOut                          : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
--
    signal iTimeOutEEPIn                     : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
    signal timeOutEEPOut                     : std_logic_vector (gNumberOfInternalPort - 1 downto 0);
--
    signal routingSwitch                     : std_logic_vector ((gNumberOfInternalPort*gNumberOfInternalPort - 1) downto 0);
--
    signal routerTimeCode                    : std_logic_vector (7 downto 0);
    signal transmitTimeCodeEnable            : std_logic_vector (6 downto 0);
--
    -- [[[cog
    -- for i in range(1, int(nports)+1):
    --   print(f"signal port{i}TickIn                       : std_logic;")
    --   print(f"signal port{i}TiemCodeIn                   : std_logic_vector (7 downto 0);")
    --   print(f"signal port{i}TickOut                      : std_logic;")
    --   print(f"signal port{i}TimeCodeOut                  : std_logic_vector (7 downto 0);")
    -- ]]]
    signal port1TickIn                       : std_logic;
    signal port1TiemCodeIn                   : std_logic_vector (7 downto 0);
    signal port1TickOut                      : std_logic;
    signal port1TimeCodeOut                  : std_logic_vector (7 downto 0);
    signal port2TickIn                       : std_logic;
    signal port2TiemCodeIn                   : std_logic_vector (7 downto 0);
    signal port2TickOut                      : std_logic;
    signal port2TimeCodeOut                  : std_logic_vector (7 downto 0);
    signal port3TickIn                       : std_logic;
    signal port3TiemCodeIn                   : std_logic_vector (7 downto 0);
    signal port3TickOut                      : std_logic;
    signal port3TimeCodeOut                  : std_logic_vector (7 downto 0);
    signal port4TickIn                       : std_logic;
    signal port4TiemCodeIn                   : std_logic_vector (7 downto 0);
    signal port4TickOut                      : std_logic;
    signal port4TimeCodeOut                  : std_logic_vector (7 downto 0);
    signal port5TickIn                       : std_logic;
    signal port5TiemCodeIn                   : std_logic_vector (7 downto 0);
    signal port5TickOut                      : std_logic;
    signal port5TimeCodeOut                  : std_logic_vector (7 downto 0);
    signal port6TickIn                       : std_logic;
    signal port6TiemCodeIn                   : std_logic_vector (7 downto 0);
    signal port6TickOut                      : std_logic;
    signal port6TimeCodeOut                  : std_logic_vector (7 downto 0);
    -- [[[end]]]
--
    -- [[[cog
    -- a = []; b = []; c = [];
    -- for i in range(1, int(nports)+1):
    --   a.append(f"signal port{i}LinkReset                    : std_logic;")
    --   a.append(f"signal port{i}LinkStatus                   : std_logic_vector (15 downto 0);")
    --   a.append(f"signal port{i}ErrorStatus                  : std_logic_vector (7 downto 0);")
    --   b.append(f"signal port{i}LinkControl                  : std_logic_vector (15 downto 0);")
    --   c.append(f"signal port{i}CreditCount                  : std_logic_vector (5 downto 0);")
    --   c.append(f"signal port{i}OutstandingCount             : std_logic_vector (5 downto 0);")
    --   c.append(f"signal port{i}CreditCountSynchronized      : std_logic_vector (5 downto 0);")
    --   c.append(f"signal port{i}OutstandingCountSynchronized : std_logic_vector (5 downto 0);")
    -- msg = "\n".join(a + b + c)
    -- print(msg)
    -- ]]]
    signal port1LinkReset                    : std_logic;
    signal port1LinkStatus                   : std_logic_vector (15 downto 0);
    signal port1ErrorStatus                  : std_logic_vector (7 downto 0);
    signal port2LinkReset                    : std_logic;
    signal port2LinkStatus                   : std_logic_vector (15 downto 0);
    signal port2ErrorStatus                  : std_logic_vector (7 downto 0);
    signal port3LinkReset                    : std_logic;
    signal port3LinkStatus                   : std_logic_vector (15 downto 0);
    signal port3ErrorStatus                  : std_logic_vector (7 downto 0);
    signal port4LinkReset                    : std_logic;
    signal port4LinkStatus                   : std_logic_vector (15 downto 0);
    signal port4ErrorStatus                  : std_logic_vector (7 downto 0);
    signal port5LinkReset                    : std_logic;
    signal port5LinkStatus                   : std_logic_vector (15 downto 0);
    signal port5ErrorStatus                  : std_logic_vector (7 downto 0);
    signal port6LinkReset                    : std_logic;
    signal port6LinkStatus                   : std_logic_vector (15 downto 0);
    signal port6ErrorStatus                  : std_logic_vector (7 downto 0);
    signal port1LinkControl                  : std_logic_vector (15 downto 0);
    signal port2LinkControl                  : std_logic_vector (15 downto 0);
    signal port3LinkControl                  : std_logic_vector (15 downto 0);
    signal port4LinkControl                  : std_logic_vector (15 downto 0);
    signal port5LinkControl                  : std_logic_vector (15 downto 0);
    signal port6LinkControl                  : std_logic_vector (15 downto 0);
    signal port1CreditCount                  : std_logic_vector (5 downto 0);
    signal port1OutstandingCount             : std_logic_vector (5 downto 0);
    signal port1CreditCountSynchronized      : std_logic_vector (5 downto 0);
    signal port1OutstandingCountSynchronized : std_logic_vector (5 downto 0);
    signal port2CreditCount                  : std_logic_vector (5 downto 0);
    signal port2OutstandingCount             : std_logic_vector (5 downto 0);
    signal port2CreditCountSynchronized      : std_logic_vector (5 downto 0);
    signal port2OutstandingCountSynchronized : std_logic_vector (5 downto 0);
    signal port3CreditCount                  : std_logic_vector (5 downto 0);
    signal port3OutstandingCount             : std_logic_vector (5 downto 0);
    signal port3CreditCountSynchronized      : std_logic_vector (5 downto 0);
    signal port3OutstandingCountSynchronized : std_logic_vector (5 downto 0);
    signal port4CreditCount                  : std_logic_vector (5 downto 0);
    signal port4OutstandingCount             : std_logic_vector (5 downto 0);
    signal port4CreditCountSynchronized      : std_logic_vector (5 downto 0);
    signal port4OutstandingCountSynchronized : std_logic_vector (5 downto 0);
    signal port5CreditCount                  : std_logic_vector (5 downto 0);
    signal port5OutstandingCount             : std_logic_vector (5 downto 0);
    signal port5CreditCountSynchronized      : std_logic_vector (5 downto 0);
    signal port5OutstandingCountSynchronized : std_logic_vector (5 downto 0);
    signal port6CreditCount                  : std_logic_vector (5 downto 0);
    signal port6OutstandingCount             : std_logic_vector (5 downto 0);
    signal port6CreditCountSynchronized      : std_logic_vector (5 downto 0);
    signal port6OutstandingCountSynchronized : std_logic_vector (5 downto 0);
    -- [[[end]]]
--
    signal timeOutEnable                     : std_logic;
    signal timeOutCountValue                 : std_logic_vector (19 downto 0);
--
    type   bit32X9Array is array (8 downto 0) of std_logic_vector (31 downto 0);
    type   bit8X9Array is array (8 downto 0) of std_logic_vector (7 downto 0);
    type   bit4X9Array is array (8 downto 0) of std_logic_vector (3 downto 0);
    signal busMasterAddressOut               : bit32X9Array;
    signal busMasterDataOut                  : bit32X9Array;
    signal busMasterByteEnableOut            : bit4X9Array;
    signal busMasterWriteEnableOut           : std_logic_vector (6 downto 0);
    signal busMasterRequestOut               : std_logic_vector (6 downto 0);
    signal busMasterGranted                  : std_logic_vector (7 downto 0);
    signal busMasterAcknowledgeIn            : std_logic_vector (6 downto 0);
    signal busMasterStrobeOut                : std_logic_vector (6 downto 0);
    signal busMasterOriginalPortOut          : bit8X9Array;
--
    signal iBusSlaveCycleIn                  : std_logic;
    signal iBusSlaveStrobeIn                 : std_logic;
    signal iBusSlaveAddressIn                : std_logic_vector (31 downto 0);
    signal busSlaveDataOut                   : std_logic_vector (31 downto 0);
    signal iBusSlaveDataIn                   : std_logic_vector (31 downto 0);
    signal iBusSlaveAcknowledgeOut           : std_logic;
    signal iBusSlaveWriteEnableIn            : std_logic;
    signal iBusSlaveByteEnableIn             : std_logic_vector (3 downto 0);
    signal iBusSlaveOriginalPortIn           : std_logic_vector (7 downto 0);
--
    signal port0LogicalAddress               : std_logic_vector (7 downto 0);
    signal port0RMAPKey                      : std_logic_vector (7 downto 0);
    signal port0CRCRevision                  : std_logic;
--
    signal autoTimeCodeValue                 : std_logic_vector(7 downto 0);
    signal autoTimeCodeCycleTime             : std_logic_vector(31 downto 0);
--
    signal statisticalInformation1           : bit32X8Array;
    signal statisticalInformation2           : bit32X8Array;
    signal statisticalInformation3           : bit32X8Array;
    signal statisticalInformation4           : bit32X8Array;
    signal statisticalInformation5           : bit32X8Array;
    signal statisticalInformation6           : bit32X8Array;
    signal statisticalInformationClear       : std_logic;
--
    signal dropCouterClear                   : std_logic;
    signal iBusMasterUserAcknowledgeOut      : std_logic;
--
    signal ibusMasterDataOut                 : std_logic_vector (31 downto 0);

    -- [[[cog
    -- print(f"signal iLinkUp : std_logic_vector ({n-1} downto 0);")
    -- ]]]
    signal iLinkUp : std_logic_vector (6 downto 0);
    -- [[[end]]]

begin

    oneShotStatusPort1 <= port1LinkStatus (15 downto 8);
    oneShotStatusPort2 <= port2LinkStatus (15 downto 8);
    oneShotStatusPort3 <= port3LinkStatus (15 downto 8);
    oneShotStatusPort4 <= port4LinkStatus (15 downto 8);
    oneShotStatusPort5 <= port5LinkStatus (15 downto 8);
    oneShotStatusPort6 <= port6LinkStatus (15 downto 8);

--------------------------------------------------------------------------------
-- Crossbar Switch.
--------------------------------------------------------------------------------
    arbiter : entity work.SpaceWireRouterIPArbiter7x7
        port map (
            clock              => clock,
            reset              => reset,
            -- [[[cog
            -- a = []; b = []; c = []
            -- for i in range(0, int(nports) + 1):
            --   a.append(f"destinationOfPort{i} => destinationPort ({i})")
            --   b.append(f"requestOfPort{i}     => requestOut ({i})")
            --   c.append(f"grantedToPort{i}     => granted ({i})")
            -- msg = ",\n".join(a + b + c)
            -- print(f"{msg},")
            -- ]]]
            destinationOfPort0 => destinationPort (0),
            destinationOfPort1 => destinationPort (1),
            destinationOfPort2 => destinationPort (2),
            destinationOfPort3 => destinationPort (3),
            destinationOfPort4 => destinationPort (4),
            destinationOfPort5 => destinationPort (5),
            destinationOfPort6 => destinationPort (6),
            requestOfPort0     => requestOut (0),
            requestOfPort1     => requestOut (1),
            requestOfPort2     => requestOut (2),
            requestOfPort3     => requestOut (3),
            requestOfPort4     => requestOut (4),
            requestOfPort5     => requestOut (5),
            requestOfPort6     => requestOut (6),
            grantedToPort0     => granted (0),
            grantedToPort1     => granted (1),
            grantedToPort2     => granted (2),
            grantedToPort3     => granted (3),
            grantedToPort4     => granted (4),
            grantedToPort5     => granted (5),
            grantedToPort6     => granted (6),
            -- [[[end]]]
            routingSwitch      => routingSwitch
            );

----------------------------------------------------------------------
-- The destination PortNo regarding the source PortNo.
----------------------------------------------------------------------
    -- [[[cog
    -- n = int(nports) + 1
    -- for i in range(0, int(nports) + 1):
    --   a = []
    --   for j in range(0, int(nports) + 1):
    --     a.append(f"routingSwitch ({n*j + i})")
    --   print(f"iSelectDestinationPort ({i}) <= {' & '.join(a[::-1])};")
    -- ]]]
    iSelectDestinationPort (0) <= routingSwitch (42) & routingSwitch (35) & routingSwitch (28) & routingSwitch (21) & routingSwitch (14) & routingSwitch (7) & routingSwitch (0);
    iSelectDestinationPort (1) <= routingSwitch (43) & routingSwitch (36) & routingSwitch (29) & routingSwitch (22) & routingSwitch (15) & routingSwitch (8) & routingSwitch (1);
    iSelectDestinationPort (2) <= routingSwitch (44) & routingSwitch (37) & routingSwitch (30) & routingSwitch (23) & routingSwitch (16) & routingSwitch (9) & routingSwitch (2);
    iSelectDestinationPort (3) <= routingSwitch (45) & routingSwitch (38) & routingSwitch (31) & routingSwitch (24) & routingSwitch (17) & routingSwitch (10) & routingSwitch (3);
    iSelectDestinationPort (4) <= routingSwitch (46) & routingSwitch (39) & routingSwitch (32) & routingSwitch (25) & routingSwitch (18) & routingSwitch (11) & routingSwitch (4);
    iSelectDestinationPort (5) <= routingSwitch (47) & routingSwitch (40) & routingSwitch (33) & routingSwitch (26) & routingSwitch (19) & routingSwitch (12) & routingSwitch (5);
    iSelectDestinationPort (6) <= routingSwitch (48) & routingSwitch (41) & routingSwitch (34) & routingSwitch (27) & routingSwitch (20) & routingSwitch (13) & routingSwitch (6);
    -- [[[end]]]

----------------------------------------------------------------------
-- The source to the destination PortNo PortNo.
----------------------------------------------------------------------
    -- [[[cog
    -- n = int(nports) + 1
    -- for i in range(0, int(nports) + 1):
    --   print(f"iSwitchPortNumber ({i}) <= routingSwitch ({(n-1) + n*i} downto {n*i});")
    -- ]]]
    iSwitchPortNumber (0) <= routingSwitch (6 downto 0);
    iSwitchPortNumber (1) <= routingSwitch (13 downto 7);
    iSwitchPortNumber (2) <= routingSwitch (20 downto 14);
    iSwitchPortNumber (3) <= routingSwitch (27 downto 21);
    iSwitchPortNumber (4) <= routingSwitch (34 downto 28);
    iSwitchPortNumber (5) <= routingSwitch (41 downto 35);
    iSwitchPortNumber (6) <= routingSwitch (48 downto 42);
    -- [[[end]]]

    spx : for i in 0 to gNumberOfInternalPort - 1 generate
    begin
        iReadyIn (i) <= select7x1(iSelectDestinationPort (i),
                                  -- [[[cog
                                  -- a = ",\n".join([f"readyOut ({i})" for i in range(0, int(nports)+1)])
                                  -- print(f"{a});")
                                  -- ]]]
                                  readyOut (0),
                                  readyOut (1),
                                  readyOut (2),
                                  readyOut (3),
                                  readyOut (4),
                                  readyOut (5),
                                  readyOut (6));
                                  -- [[[end]]]
    end generate;

    spx1 : for i in 0 to gNumberOfInternalPort - 1 generate
    begin
        iRequestIn (i) <= select7x1(iSwitchPortNumber (i),
                                    -- [[[cog
                                    -- a = ",\n".join([f"requestOut ({i})" for i in range(0, int(nports)+1)])
                                    -- print(f"{a});")
                                    -- ]]]
                                    requestOut (0),
                                    requestOut (1),
                                    requestOut (2),
                                    requestOut (3),
                                    requestOut (4),
                                    requestOut (5),
                                    requestOut (6));
                                    -- [[[end]]]
    end generate;

    spx2 : for i in 0 to gNumberOfInternalPort - 1 generate
    begin
        iSorcePortIn (i) <= select7x1xVector8(iSwitchPortNumber (i),
                                              -- [[[cog
                                              -- a = ",\n".join([f"sorcePortrOut ({i})" for i in range(0, int(nports)+1)])
                                              -- print(f"{a});")
                                              -- ]]]
                                              sorcePortrOut (0),
                                              sorcePortrOut (1),
                                              sorcePortrOut (2),
                                              sorcePortrOut (3),
                                              sorcePortrOut (4),
                                              sorcePortrOut (5),
                                              sorcePortrOut (6));
                                              -- [[[end]]]
    end generate;

    spx3 : for i in 0 to gNumberOfInternalPort - 1 generate
    begin

        iDataIn (i) <= select7x1xVector9(iSwitchPortNumber (i),
                                        -- [[[cog
                                        -- a = ",\n".join([f"dataOut ({i})" for i in range(0, int(nports)+1)])
                                        -- print(f"{a});")
                                        -- ]]]
                                        dataOut (0),
                                        dataOut (1),
                                        dataOut (2),
                                        dataOut (3),
                                        dataOut (4),
                                        dataOut (5),
                                        dataOut (6));
                                        -- [[[end]]]
    end generate;

    spx4 : for i in 0 to gNumberOfInternalPort - 1 generate
    begin

        iStrobeIn (i) <= select7x1(iSwitchPortNumber (i),
                                   -- [[[cog
                                   -- a = ",\n".join([f"strobeOut ({i})" for i in range(0, int(nports)+1)])
                                   -- print(f"{a});")
                                   -- ]]]
                                   strobeOut (0),
                                   strobeOut (1),
                                   strobeOut (2),
                                   strobeOut (3),
                                   strobeOut (4),
                                   strobeOut (5),
                                   strobeOut (6));
                                   -- [[[end]]]
    end generate;

    spx5 : for i in 0 to gNumberOfInternalPort - 1 generate
    begin

        iTimeOutEEPIn (i) <= select7x1(iSwitchPortNumber (i),
                                       -- [[[cog
                                       -- a = ",\n".join([f"timeOutEEPOut ({i})" for i in range(0, int(nports)+1)])
                                       -- print(f"{a});")
                                       -- ]]]
                                       timeOutEEPOut (0),
                                       timeOutEEPOut (1),
                                       timeOutEEPOut (2),
                                       timeOutEEPOut (3),
                                       timeOutEEPOut (4),
                                       timeOutEEPOut (5),
                                       timeOutEEPOut (6));
                                       -- [[[end]]]
    end generate;

----------------------------------------------------------------------
-- SpaceWirePort LinkUP Signal.
----------------------------------------------------------------------
    process(clock)
    begin
        if(clock'event and clock = '1')then
            iLinkUp (0) <= '1';
            -- [[[cog
            -- for i in range(1, int(nports) + 1):
            --   print(f"if(port{i}LinkStatus (5 downto 0) = \"111111\") then")
            --   print(f"    iLinkUp ({i}) <= '1';")
            --   print(f"else")
            --   print(f"    iLinkUp ({i}) <= '0';")
            --   print(f"end if;")
            -- ]]]
            if(port1LinkStatus (5 downto 0) = "111111") then
                iLinkUp (1) <= '1';
            else
                iLinkUp (1) <= '0';
            end if;
            if(port2LinkStatus (5 downto 0) = "111111") then
                iLinkUp (2) <= '1';
            else
                iLinkUp (2) <= '0';
            end if;
            if(port3LinkStatus (5 downto 0) = "111111") then
                iLinkUp (3) <= '1';
            else
                iLinkUp (3) <= '0';
            end if;
            if(port4LinkStatus (5 downto 0) = "111111") then
                iLinkUp (4) <= '1';
            else
                iLinkUp (4) <= '0';
            end if;
            if(port5LinkStatus (5 downto 0) = "111111") then
                iLinkUp (5) <= '1';
            else
                iLinkUp (5) <= '0';
            end if;
            if(port6LinkStatus (5 downto 0) = "111111") then
                iLinkUp (6) <= '1';
            else
                iLinkUp (6) <= '0';
            end if;
            -- [[[end]]]
        end if;
    end process;

--------------------------------------------------------------------------------
-- Internal Configuration Port.
--------------------------------------------------------------------------------
    port00 : entity work.SpaceWireRouterIPRMAPPort
        generic map (gPortNumber => x"00", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                   => clock,
            reset                   => reset,
            linkUp                  => iLinkUp,
--
            timeOutEnable           => timeOutEnable,
            timeOutCountValue       => timeOutCountValue,
            timeOutEEPOut           => timeOutEEPOut (0),
            timeOutEEPIn            => iTimeOutEEPIn (0),
            packetDropped           => packetDropped0,
--
            PortRequest             => requestOut (0),
            destinationPortOut      => destinationPort (0),
            sorcePortOut            => sorcePortrOut (0),
            grantedIn               => granted (0),
            readyIn                 => iReadyIn (0),
            dataOut                 => dataOut (0),
            strobeOut               => strobeOut (0),
--
            requestIn               => iRequestIn (0),
            sourcePortIn            => iSorcePortIn (0),
            readyOut                => readyOut (0),
            dataIn                  => iDataIn (0),
            strobeIn                => iStrobeIn (0),
--
            logicalAddress          => port0LogicalAddress,
            rmapKey                 => port0RMAPKey ,
            crcRevision             => port0CRCRevision,
--
            busMasterOriginalPort   => busMasterOriginalPortOut (0),
            busMasterRequestOut     => busMasterRequestOut (0),
            busMasterStrobeOut      => busMasterStrobeOut (0),
            busMasterAddressOut     => busMasterAddressOut (0),
            busMasterByteEnableOut  => busMasterByteEnableOut (0),
            busMasterWriteEnableOut => busMasterWriteEnableOut (0),
            busMasterDataIn         => busSlaveDataOut,
            busMasterDataOut        => busMasterDataOut (0),
            busMasterAcknowledgeIn  => busMasterAcknowledgeIn (0)
            );


--------------------------------------------------------------------------------
-- SpaceWire Physical Port.
--------------------------------------------------------------------------------
    -- [[[cog
    -- tpl = """
    -- port{i:02} : entity work.SpaceWireRouterIPSpaceWirePort
    --     generic map (gNumberOfInternalPort => x"{i:02x}", gNumberOfExternalPort => cNumberOfExternalPort)
    --     port map (
    --         clock                       => clock,
    --         transmitClock               => transmitClock,
    --         receiveClock                => receiveClock,
    --         reset                       => reset,
    --
    --         linkUp                      => iLinkUp,
    --
    --         timeOutEnable               => timeOutEnable,
    --         timeOutCountValue           => timeOutCountValue,
    --         timeOutEEPOut               => timeOutEEPOut ({i}),
    --         timeOutEEPIn                => iTimeOutEEPIn ({i}),
    --         packetDropped               => packetDropped{i},
    --
    --         requestOut                  => requestOut ({i}),
    --         destinationPortOut          => destinationPort ({i}),
    --         sourcePorOut                => sorcePortrOut ({i}),
    --         grantedIn                   => granted ({i}),
    --         readyIn                     => iReadyIn ({i}),
    --         dataOut                     => dataOut ({i}),
    --         strobeOut                   => strobeOut ({i}),
    --
    --         requestIn                   => iRequestIn ({i}),
    --         readyOut                    => readyOut ({i}),
    --         dataIn                      => iDataIn ({i}),
    --         strobeIn                    => iStrobeIn ({i}),
    --
    --         busMasterRequestOut         => busMasterRequestOut ({i}),
    --         busMasterStrobeOut          => busMasterStrobeOut ({i}),
    --         busMasterAddressOut         => busMasterAddressOut ({i}),
    --         busMasterByteEnableOut      => busMasterByteEnableOut ({i}),
    --         busMasterWriteEnableOut     => busMasterWriteEnableOut ({i}),
    --         busMasterDataIn             => busSlaveDataOut,
    --         busMasterDataOut            => busMasterDataOut ({i}),
    --         busMasterAcknowledgeIn      => busMasterAcknowledgeIn ({i}),
    --
    --         tickIn                      => port{i}TickIn,
    --         timeCodeIn                  => port{i}TiemCodeIn,
    --         tickOut                     => port{i}TickOut,
    --         timeCodeOut                 => port{i}TimeCodeOut,
    --
    --         linkStart                   => port{i}LinkControl (0),
    --         linkDisable                 => port{i}LinkControl (1),
    --         autoStart                   => port{i}LinkControl (2),
    --         linkReset                   => port{i}LinkReset,
    --         transmitClockDivide         => port{i}LinkControl (13 downto 8),
    --         linkStatus                  => port{i}LinkStatus,
    --         errorStatus                 => port{i}ErrorStatus,
    --         creditCount                 => port{i}CreditCount,
    --         outstandingCount            => port{i}OutstandingCount,
    --
    --         spaceWireDataOut            => spaceWireDataOut{i},
    --         spaceWireStrobeOut          => spaceWireStrobeOut{i},
    --         spaceWireDataIn             => spaceWireDataIn{i},
    --         spaceWireStrobeIn           => spaceWireStrobeIn{i},
    --
    --         statisticalInformationClear => statisticalInformationClear,
    --         statisticalInformation      => statisticalInformation{i}
    --         );
    -- """
    -- for i in range(1, int(nports) + 1):
    --   print(tpl.format(i = i))
    -- ]]]

    port01 : entity work.SpaceWireRouterIPSpaceWirePort
        generic map (gNumberOfInternalPort => x"01", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            reset                       => reset,

            linkUp                      => iLinkUp,

            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
            timeOutEEPOut               => timeOutEEPOut (1),
            timeOutEEPIn                => iTimeOutEEPIn (1),
            packetDropped               => packetDropped1,

            requestOut                  => requestOut (1),
            destinationPortOut          => destinationPort (1),
            sourcePorOut                => sorcePortrOut (1),
            grantedIn                   => granted (1),
            readyIn                     => iReadyIn (1),
            dataOut                     => dataOut (1),
            strobeOut                   => strobeOut (1),

            requestIn                   => iRequestIn (1),
            readyOut                    => readyOut (1),
            dataIn                      => iDataIn (1),
            strobeIn                    => iStrobeIn (1),

            busMasterRequestOut         => busMasterRequestOut (1),
            busMasterStrobeOut          => busMasterStrobeOut (1),
            busMasterAddressOut         => busMasterAddressOut (1),
            busMasterByteEnableOut      => busMasterByteEnableOut (1),
            busMasterWriteEnableOut     => busMasterWriteEnableOut (1),
            busMasterDataIn             => busSlaveDataOut,
            busMasterDataOut            => busMasterDataOut (1),
            busMasterAcknowledgeIn      => busMasterAcknowledgeIn (1),

            tickIn                      => port1TickIn,
            timeCodeIn                  => port1TiemCodeIn,
            tickOut                     => port1TickOut,
            timeCodeOut                 => port1TimeCodeOut,

            linkStart                   => port1LinkControl (0),
            linkDisable                 => port1LinkControl (1),
            autoStart                   => port1LinkControl (2),
            linkReset                   => port1LinkReset,
            transmitClockDivide         => port1LinkControl (13 downto 8),
            linkStatus                  => port1LinkStatus,
            errorStatus                 => port1ErrorStatus,
            creditCount                 => port1CreditCount,
            outstandingCount            => port1OutstandingCount,

            spaceWireDataOut            => spaceWireDataOut1,
            spaceWireStrobeOut          => spaceWireStrobeOut1,
            spaceWireDataIn             => spaceWireDataIn1,
            spaceWireStrobeIn           => spaceWireStrobeIn1,

            statisticalInformationClear => statisticalInformationClear,
            statisticalInformation      => statisticalInformation1
            );


    port02 : entity work.SpaceWireRouterIPSpaceWirePort
        generic map (gNumberOfInternalPort => x"02", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            reset                       => reset,

            linkUp                      => iLinkUp,

            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
            timeOutEEPOut               => timeOutEEPOut (2),
            timeOutEEPIn                => iTimeOutEEPIn (2),
            packetDropped               => packetDropped2,

            requestOut                  => requestOut (2),
            destinationPortOut          => destinationPort (2),
            sourcePorOut                => sorcePortrOut (2),
            grantedIn                   => granted (2),
            readyIn                     => iReadyIn (2),
            dataOut                     => dataOut (2),
            strobeOut                   => strobeOut (2),

            requestIn                   => iRequestIn (2),
            readyOut                    => readyOut (2),
            dataIn                      => iDataIn (2),
            strobeIn                    => iStrobeIn (2),

            busMasterRequestOut         => busMasterRequestOut (2),
            busMasterStrobeOut          => busMasterStrobeOut (2),
            busMasterAddressOut         => busMasterAddressOut (2),
            busMasterByteEnableOut      => busMasterByteEnableOut (2),
            busMasterWriteEnableOut     => busMasterWriteEnableOut (2),
            busMasterDataIn             => busSlaveDataOut,
            busMasterDataOut            => busMasterDataOut (2),
            busMasterAcknowledgeIn      => busMasterAcknowledgeIn (2),

            tickIn                      => port2TickIn,
            timeCodeIn                  => port2TiemCodeIn,
            tickOut                     => port2TickOut,
            timeCodeOut                 => port2TimeCodeOut,

            linkStart                   => port2LinkControl (0),
            linkDisable                 => port2LinkControl (1),
            autoStart                   => port2LinkControl (2),
            linkReset                   => port2LinkReset,
            transmitClockDivide         => port2LinkControl (13 downto 8),
            linkStatus                  => port2LinkStatus,
            errorStatus                 => port2ErrorStatus,
            creditCount                 => port2CreditCount,
            outstandingCount            => port2OutstandingCount,

            spaceWireDataOut            => spaceWireDataOut2,
            spaceWireStrobeOut          => spaceWireStrobeOut2,
            spaceWireDataIn             => spaceWireDataIn2,
            spaceWireStrobeIn           => spaceWireStrobeIn2,

            statisticalInformationClear => statisticalInformationClear,
            statisticalInformation      => statisticalInformation2
            );


    port03 : entity work.SpaceWireRouterIPSpaceWirePort
        generic map (gNumberOfInternalPort => x"03", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            reset                       => reset,

            linkUp                      => iLinkUp,

            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
            timeOutEEPOut               => timeOutEEPOut (3),
            timeOutEEPIn                => iTimeOutEEPIn (3),
            packetDropped               => packetDropped3,

            requestOut                  => requestOut (3),
            destinationPortOut          => destinationPort (3),
            sourcePorOut                => sorcePortrOut (3),
            grantedIn                   => granted (3),
            readyIn                     => iReadyIn (3),
            dataOut                     => dataOut (3),
            strobeOut                   => strobeOut (3),

            requestIn                   => iRequestIn (3),
            readyOut                    => readyOut (3),
            dataIn                      => iDataIn (3),
            strobeIn                    => iStrobeIn (3),

            busMasterRequestOut         => busMasterRequestOut (3),
            busMasterStrobeOut          => busMasterStrobeOut (3),
            busMasterAddressOut         => busMasterAddressOut (3),
            busMasterByteEnableOut      => busMasterByteEnableOut (3),
            busMasterWriteEnableOut     => busMasterWriteEnableOut (3),
            busMasterDataIn             => busSlaveDataOut,
            busMasterDataOut            => busMasterDataOut (3),
            busMasterAcknowledgeIn      => busMasterAcknowledgeIn (3),

            tickIn                      => port3TickIn,
            timeCodeIn                  => port3TiemCodeIn,
            tickOut                     => port3TickOut,
            timeCodeOut                 => port3TimeCodeOut,

            linkStart                   => port3LinkControl (0),
            linkDisable                 => port3LinkControl (1),
            autoStart                   => port3LinkControl (2),
            linkReset                   => port3LinkReset,
            transmitClockDivide         => port3LinkControl (13 downto 8),
            linkStatus                  => port3LinkStatus,
            errorStatus                 => port3ErrorStatus,
            creditCount                 => port3CreditCount,
            outstandingCount            => port3OutstandingCount,

            spaceWireDataOut            => spaceWireDataOut3,
            spaceWireStrobeOut          => spaceWireStrobeOut3,
            spaceWireDataIn             => spaceWireDataIn3,
            spaceWireStrobeIn           => spaceWireStrobeIn3,

            statisticalInformationClear => statisticalInformationClear,
            statisticalInformation      => statisticalInformation3
            );


    port04 : entity work.SpaceWireRouterIPSpaceWirePort
        generic map (gNumberOfInternalPort => x"04", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            reset                       => reset,

            linkUp                      => iLinkUp,

            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
            timeOutEEPOut               => timeOutEEPOut (4),
            timeOutEEPIn                => iTimeOutEEPIn (4),
            packetDropped               => packetDropped4,

            requestOut                  => requestOut (4),
            destinationPortOut          => destinationPort (4),
            sourcePorOut                => sorcePortrOut (4),
            grantedIn                   => granted (4),
            readyIn                     => iReadyIn (4),
            dataOut                     => dataOut (4),
            strobeOut                   => strobeOut (4),

            requestIn                   => iRequestIn (4),
            readyOut                    => readyOut (4),
            dataIn                      => iDataIn (4),
            strobeIn                    => iStrobeIn (4),

            busMasterRequestOut         => busMasterRequestOut (4),
            busMasterStrobeOut          => busMasterStrobeOut (4),
            busMasterAddressOut         => busMasterAddressOut (4),
            busMasterByteEnableOut      => busMasterByteEnableOut (4),
            busMasterWriteEnableOut     => busMasterWriteEnableOut (4),
            busMasterDataIn             => busSlaveDataOut,
            busMasterDataOut            => busMasterDataOut (4),
            busMasterAcknowledgeIn      => busMasterAcknowledgeIn (4),

            tickIn                      => port4TickIn,
            timeCodeIn                  => port4TiemCodeIn,
            tickOut                     => port4TickOut,
            timeCodeOut                 => port4TimeCodeOut,

            linkStart                   => port4LinkControl (0),
            linkDisable                 => port4LinkControl (1),
            autoStart                   => port4LinkControl (2),
            linkReset                   => port4LinkReset,
            transmitClockDivide         => port4LinkControl (13 downto 8),
            linkStatus                  => port4LinkStatus,
            errorStatus                 => port4ErrorStatus,
            creditCount                 => port4CreditCount,
            outstandingCount            => port4OutstandingCount,

            spaceWireDataOut            => spaceWireDataOut4,
            spaceWireStrobeOut          => spaceWireStrobeOut4,
            spaceWireDataIn             => spaceWireDataIn4,
            spaceWireStrobeIn           => spaceWireStrobeIn4,

            statisticalInformationClear => statisticalInformationClear,
            statisticalInformation      => statisticalInformation4
            );


    port05 : entity work.SpaceWireRouterIPSpaceWirePort
        generic map (gNumberOfInternalPort => x"05", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            reset                       => reset,

            linkUp                      => iLinkUp,

            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
            timeOutEEPOut               => timeOutEEPOut (5),
            timeOutEEPIn                => iTimeOutEEPIn (5),
            packetDropped               => packetDropped5,

            requestOut                  => requestOut (5),
            destinationPortOut          => destinationPort (5),
            sourcePorOut                => sorcePortrOut (5),
            grantedIn                   => granted (5),
            readyIn                     => iReadyIn (5),
            dataOut                     => dataOut (5),
            strobeOut                   => strobeOut (5),

            requestIn                   => iRequestIn (5),
            readyOut                    => readyOut (5),
            dataIn                      => iDataIn (5),
            strobeIn                    => iStrobeIn (5),

            busMasterRequestOut         => busMasterRequestOut (5),
            busMasterStrobeOut          => busMasterStrobeOut (5),
            busMasterAddressOut         => busMasterAddressOut (5),
            busMasterByteEnableOut      => busMasterByteEnableOut (5),
            busMasterWriteEnableOut     => busMasterWriteEnableOut (5),
            busMasterDataIn             => busSlaveDataOut,
            busMasterDataOut            => busMasterDataOut (5),
            busMasterAcknowledgeIn      => busMasterAcknowledgeIn (5),

            tickIn                      => port5TickIn,
            timeCodeIn                  => port5TiemCodeIn,
            tickOut                     => port5TickOut,
            timeCodeOut                 => port5TimeCodeOut,

            linkStart                   => port5LinkControl (0),
            linkDisable                 => port5LinkControl (1),
            autoStart                   => port5LinkControl (2),
            linkReset                   => port5LinkReset,
            transmitClockDivide         => port5LinkControl (13 downto 8),
            linkStatus                  => port5LinkStatus,
            errorStatus                 => port5ErrorStatus,
            creditCount                 => port5CreditCount,
            outstandingCount            => port5OutstandingCount,

            spaceWireDataOut            => spaceWireDataOut5,
            spaceWireStrobeOut          => spaceWireStrobeOut5,
            spaceWireDataIn             => spaceWireDataIn5,
            spaceWireStrobeIn           => spaceWireStrobeIn5,

            statisticalInformationClear => statisticalInformationClear,
            statisticalInformation      => statisticalInformation5
            );


    port06 : entity work.SpaceWireRouterIPSpaceWirePort
        generic map (gNumberOfInternalPort => x"06", gNumberOfExternalPort => cNumberOfExternalPort)
        port map (
            clock                       => clock,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            reset                       => reset,

            linkUp                      => iLinkUp,

            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
            timeOutEEPOut               => timeOutEEPOut (6),
            timeOutEEPIn                => iTimeOutEEPIn (6),
            packetDropped               => packetDropped6,

            requestOut                  => requestOut (6),
            destinationPortOut          => destinationPort (6),
            sourcePorOut                => sorcePortrOut (6),
            grantedIn                   => granted (6),
            readyIn                     => iReadyIn (6),
            dataOut                     => dataOut (6),
            strobeOut                   => strobeOut (6),

            requestIn                   => iRequestIn (6),
            readyOut                    => readyOut (6),
            dataIn                      => iDataIn (6),
            strobeIn                    => iStrobeIn (6),

            busMasterRequestOut         => busMasterRequestOut (6),
            busMasterStrobeOut          => busMasterStrobeOut (6),
            busMasterAddressOut         => busMasterAddressOut (6),
            busMasterByteEnableOut      => busMasterByteEnableOut (6),
            busMasterWriteEnableOut     => busMasterWriteEnableOut (6),
            busMasterDataIn             => busSlaveDataOut,
            busMasterDataOut            => busMasterDataOut (6),
            busMasterAcknowledgeIn      => busMasterAcknowledgeIn (6),

            tickIn                      => port6TickIn,
            timeCodeIn                  => port6TiemCodeIn,
            tickOut                     => port6TickOut,
            timeCodeOut                 => port6TimeCodeOut,

            linkStart                   => port6LinkControl (0),
            linkDisable                 => port6LinkControl (1),
            autoStart                   => port6LinkControl (2),
            linkReset                   => port6LinkReset,
            transmitClockDivide         => port6LinkControl (13 downto 8),
            linkStatus                  => port6LinkStatus,
            errorStatus                 => port6ErrorStatus,
            creditCount                 => port6CreditCount,
            outstandingCount            => port6OutstandingCount,

            spaceWireDataOut            => spaceWireDataOut6,
            spaceWireStrobeOut          => spaceWireStrobeOut6,
            spaceWireDataIn             => spaceWireDataIn6,
            spaceWireStrobeIn           => spaceWireStrobeIn6,

            statisticalInformationClear => statisticalInformationClear,
            statisticalInformation      => statisticalInformation6
            );

    -- [[[end]]]

    -- [[[cog
    -- tmpl = """
    -- creditCount{i:02} : entity work.SpaceWireRouterIPCreditCount
    -- port map (
    --     clock                       => clock,
    --     transmitClock               => transmitClock,
    --     reset                       => reset,
    --     creditCount                 => port{i}CreditCount,
    --     outstndingCount             => port{i}OutstandingCount,
    --     creditCountSynchronized     => port{i}CreditCountSynchronized,
    --     outstndingCountSynchronized => port{i}OutstandingCountSynchronized
    --     );
    -- """
    -- for i in range(1, int(nports) + 1):
    --   print(tmpl.format(i = i))
    -- ]]]

    creditCount01 : entity work.SpaceWireRouterIPCreditCount
    port map (
        clock                       => clock,
        transmitClock               => transmitClock,
        reset                       => reset,
        creditCount                 => port1CreditCount,
        outstndingCount             => port1OutstandingCount,
        creditCountSynchronized     => port1CreditCountSynchronized,
        outstndingCountSynchronized => port1OutstandingCountSynchronized
        );


    creditCount02 : entity work.SpaceWireRouterIPCreditCount
    port map (
        clock                       => clock,
        transmitClock               => transmitClock,
        reset                       => reset,
        creditCount                 => port2CreditCount,
        outstndingCount             => port2OutstandingCount,
        creditCountSynchronized     => port2CreditCountSynchronized,
        outstndingCountSynchronized => port2OutstandingCountSynchronized
        );


    creditCount03 : entity work.SpaceWireRouterIPCreditCount
    port map (
        clock                       => clock,
        transmitClock               => transmitClock,
        reset                       => reset,
        creditCount                 => port3CreditCount,
        outstndingCount             => port3OutstandingCount,
        creditCountSynchronized     => port3CreditCountSynchronized,
        outstndingCountSynchronized => port3OutstandingCountSynchronized
        );


    creditCount04 : entity work.SpaceWireRouterIPCreditCount
    port map (
        clock                       => clock,
        transmitClock               => transmitClock,
        reset                       => reset,
        creditCount                 => port4CreditCount,
        outstndingCount             => port4OutstandingCount,
        creditCountSynchronized     => port4CreditCountSynchronized,
        outstndingCountSynchronized => port4OutstandingCountSynchronized
        );


    creditCount05 : entity work.SpaceWireRouterIPCreditCount
    port map (
        clock                       => clock,
        transmitClock               => transmitClock,
        reset                       => reset,
        creditCount                 => port5CreditCount,
        outstndingCount             => port5OutstandingCount,
        creditCountSynchronized     => port5CreditCountSynchronized,
        outstndingCountSynchronized => port5OutstandingCountSynchronized
        );


    creditCount06 : entity work.SpaceWireRouterIPCreditCount
    port map (
        clock                       => clock,
        transmitClock               => transmitClock,
        reset                       => reset,
        creditCount                 => port6CreditCount,
        outstndingCount             => port6OutstandingCount,
        creditCountSynchronized     => port6CreditCountSynchronized,
        outstndingCountSynchronized => port6OutstandingCountSynchronized
        );

    -- [[[end]]]

    statisticsCounters : entity work.SpaceWireRouterIPStatisticsCounter7
        port map (
            clock                 => clock,
            reset                 => reset,
            allCounterClear       => dropCouterClear,
            -- [[[cog
            -- tmpl = """
            -- watchdogTimeOut{i}      => timeOutEEPOut ({i}),
            -- packetDropped{i}        => packetDropped{i},
            -- watchdogTimeOutCount{i} => timeOutCount{i},
            -- dropCount{i}            => packetDropCount{i}
            -- """.strip()
            -- a = []
            -- for i in range(0, int(nports) + 1):
            --   a.append(tmpl.format(i = i))
            -- msg = ",\n".join(a)
            -- print(msg)
            -- ]]]
            watchdogTimeOut0      => timeOutEEPOut (0),
            packetDropped0        => packetDropped0,
            watchdogTimeOutCount0 => timeOutCount0,
            dropCount0            => packetDropCount0,
            watchdogTimeOut1      => timeOutEEPOut (1),
            packetDropped1        => packetDropped1,
            watchdogTimeOutCount1 => timeOutCount1,
            dropCount1            => packetDropCount1,
            watchdogTimeOut2      => timeOutEEPOut (2),
            packetDropped2        => packetDropped2,
            watchdogTimeOutCount2 => timeOutCount2,
            dropCount2            => packetDropCount2,
            watchdogTimeOut3      => timeOutEEPOut (3),
            packetDropped3        => packetDropped3,
            watchdogTimeOutCount3 => timeOutCount3,
            dropCount3            => packetDropCount3,
            watchdogTimeOut4      => timeOutEEPOut (4),
            packetDropped4        => packetDropped4,
            watchdogTimeOutCount4 => timeOutCount4,
            dropCount4            => packetDropCount4,
            watchdogTimeOut5      => timeOutEEPOut (5),
            packetDropped5        => packetDropped5,
            watchdogTimeOutCount5 => timeOutCount5,
            dropCount5            => packetDropCount5,
            watchdogTimeOut6      => timeOutEEPOut (6),
            packetDropped6        => packetDropped6,
            watchdogTimeOutCount6 => timeOutCount6,
            dropCount6            => packetDropCount6
            -- [[[end]]]
            );


    -- [[[cog
    -- for i in range(1, int(nports) + 1):
    --   print(f"statisticalInformationPort{i} <= statisticalInformation{i};")
    -- ]]]
    statisticalInformationPort1 <= statisticalInformation1;
    statisticalInformationPort2 <= statisticalInformation2;
    statisticalInformationPort3 <= statisticalInformation3;
    statisticalInformationPort4 <= statisticalInformation4;
    statisticalInformationPort5 <= statisticalInformation5;
    statisticalInformationPort6 <= statisticalInformation6;
    -- [[[end]]]

--------------------------------------------------------------------------------
-- Router Link Control, Status Registers and Routing Table.
--------------------------------------------------------------------------------
    routerControlRegister : entity work.SpaceWireRouterIPRouterControlRegister
        port map (
            clock         => clock,
            reset         => reset,
            transmitClock => transmitClock,
            receiveClock  => receiveClock,
--
            writeData     => iBusSlaveDataIn,

            readData                    => ibusMasterDataOut,
            acknowledge                 => iBusSlaveAcknowledgeOut,
            address                     => iBusSlaveAddressIn,
            strobe                      => iBusSlaveStrobeIn,
            cycle                       => iBusSlaveCycleIn,
            writeEnable                 => iBusSlaveWriteEnableIn,
            dataByteEnable              => iBusSlaveByteEnableIn,
            requestPort                 => iBusSlaveOriginalPortIn,
--
            linkUp                      => iLinkUp,

            -- [[[cog
            -- tmpl = """
            -- linkControl{i}                => port{i}LinkControl,
            -- linkStatus{i}                 => port{i}LinkStatus(7 downto 0),
            -- errorStatus{i}                => port{i}ErrorStatus,
            -- linkReset{i}                  => port{i}LinkReset,
            -- """.rstrip()
            -- for i in range(1, int(nports) + 1):
            --   print(tmpl.format(i = i))
            -- ]]]

            linkControl1                => port1LinkControl,
            linkStatus1                 => port1LinkStatus(7 downto 0),
            errorStatus1                => port1ErrorStatus,
            linkReset1                  => port1LinkReset,

            linkControl2                => port2LinkControl,
            linkStatus2                 => port2LinkStatus(7 downto 0),
            errorStatus2                => port2ErrorStatus,
            linkReset2                  => port2LinkReset,

            linkControl3                => port3LinkControl,
            linkStatus3                 => port3LinkStatus(7 downto 0),
            errorStatus3                => port3ErrorStatus,
            linkReset3                  => port3LinkReset,

            linkControl4                => port4LinkControl,
            linkStatus4                 => port4LinkStatus(7 downto 0),
            errorStatus4                => port4ErrorStatus,
            linkReset4                  => port4LinkReset,

            linkControl5                => port5LinkControl,
            linkStatus5                 => port5LinkStatus(7 downto 0),
            errorStatus5                => port5ErrorStatus,
            linkReset5                  => port5LinkReset,

            linkControl6                => port6LinkControl,
            linkStatus6                 => port6LinkStatus(7 downto 0),
            errorStatus6                => port6ErrorStatus,
            linkReset6                  => port6LinkReset,
            -- [[[end]]]
--
            -- [[[cog
            -- a = []; b = [];
            -- for i in range (1, int(nports)+1):
            --   a.append(f"creditCount{i}                => port{i}CreditCountSynchronized")
            --   b.append(f"outstandingCount{i}           => port{i}OutstandingCountSynchronized")
            -- s = ",\n".join(a + b)
            -- print(f"{s},")
            -- ]]]
            creditCount1                => port1CreditCountSynchronized,
            creditCount2                => port2CreditCountSynchronized,
            creditCount3                => port3CreditCountSynchronized,
            creditCount4                => port4CreditCountSynchronized,
            creditCount5                => port5CreditCountSynchronized,
            creditCount6                => port6CreditCountSynchronized,
            outstandingCount1           => port1OutstandingCountSynchronized,
            outstandingCount2           => port2OutstandingCountSynchronized,
            outstandingCount3           => port3OutstandingCountSynchronized,
            outstandingCount4           => port4OutstandingCountSynchronized,
            outstandingCount5           => port5OutstandingCountSynchronized,
            outstandingCount6           => port6OutstandingCountSynchronized,
            -- [[[end]]]
            -- [[[cog
            -- a = []; b = [];
            -- for i in range (0, int(nports)+1):
            --   a.append(f"timeOutCount{i}               => timeOutCount{i}")
            --   b.append(f"dropCount{i}                  => packetDropCount{i}")
            -- s = ",\n".join(a + b)
            -- print(f"{s},")
            -- ]]]
            timeOutCount0               => timeOutCount0,
            timeOutCount1               => timeOutCount1,
            timeOutCount2               => timeOutCount2,
            timeOutCount3               => timeOutCount3,
            timeOutCount4               => timeOutCount4,
            timeOutCount5               => timeOutCount5,
            timeOutCount6               => timeOutCount6,
            dropCount0                  => packetDropCount0,
            dropCount1                  => packetDropCount1,
            dropCount2                  => packetDropCount2,
            dropCount3                  => packetDropCount3,
            dropCount4                  => packetDropCount4,
            dropCount5                  => packetDropCount5,
            dropCount6                  => packetDropCount6,
            -- [[[end]]]
--
            dropCouterClear             => dropCouterClear,
--
            timeOutEnable               => timeOutEnable,
            timeOutCountValue           => timeOutCountValue,
--
            receiveTimeCode             => routerTimeCode,
            transmitTimeCodeEnable      => transmitTimeCodeEnable,
--
            port0TargetLogicalAddress   => port0LogicalAddress,
            port0RMAPKey                => port0RMAPKey,
            port0CRCRevision            => port0CRCRevision,
--
            autoTimeCodeValue           => autoTimeCodeValue,
            autoTimeCodeCycleTime       => autoTimeCodeCycleTime,
--
            -- [[[cog
            -- a = []; b = [];
            -- for i in range (1, int(nports)+1):
            --   a.append(f"statisticalInformation{i}     => statisticalInformation{i}")
            -- s = ",\n".join(a)
            -- print(f"{s},")
            -- ]]]
            statisticalInformation1     => statisticalInformation1,
            statisticalInformation2     => statisticalInformation2,
            statisticalInformation3     => statisticalInformation3,
            statisticalInformation4     => statisticalInformation4,
            statisticalInformation5     => statisticalInformation5,
            statisticalInformation6     => statisticalInformation6,
            -- [[[end]]]
            statisticalInformationClear => statisticalInformationClear
            );


--------------------------------------------------------------------------------
-- Bus arbiter.
--------------------------------------------------------------------------------
    busAbiter : entity work.SpaceWireRouterIPTableArbiter7 port map (
        clock               => clock,
        reset               => reset,
        -- [[[cog
        -- n = int(nports)
        -- print(f"request({n} downto 0) => busMasterRequestOut,")
        -- print(f"request({n+1})          => busMasterUserRequestIn,")
        -- ]]]
        request(6 downto 0) => busMasterRequestOut,
        request(7)          => busMasterUserRequestIn,
        -- [[[end]]]
        granted             => busMasterGranted
        );


----------------------------------------------------------------------
-- Timing adjustment.
-- BusSlaveAccessSelector.
----------------------------------------------------------------------
    process(reset, clock)
    begin
        if (reset = '1') then
          iBusSlaveStrobeIn       <= '0';
          iBusSlaveAddressIn      <= (others => '0');
          iBusSlaveByteEnableIn   <= (others => '0');
          iBusSlaveWriteEnableIn  <= '0';
          iBusSlaveOriginalPortIn <= (others => '0');
          iBusSlaveDataIn         <= (others => '0');
          busMasterAcknowledgeIn  <= (others => '0');
        elsif (clock'event and clock = '1') then
            if (
              -- [[[cog
              -- a = " or\n".join([f"busMasterRequestOut({i}) = '1'" for i in range(0, int(nports)+1)])
              -- print(f"{a} or")
              -- ]]]
              busMasterRequestOut(0) = '1' or
              busMasterRequestOut(1) = '1' or
              busMasterRequestOut(2) = '1' or
              busMasterRequestOut(3) = '1' or
              busMasterRequestOut(4) = '1' or
              busMasterRequestOut(5) = '1' or
              busMasterRequestOut(6) = '1' or
              -- [[[end]]]
              busMasterUserRequestIn = '1') then
              iBusSlaveCycleIn <= '1';
            else
                iBusSlaveCycleIn <= '0';
            end if;
--
            if (busMasterGranted(0) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (0);
                iBusSlaveAddressIn      <= busMasterAddressOut (0);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (0);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (0);
                iBusSlaveOriginalPortIn <= busMasterOriginalPortOut(0);
                iBusSlaveDataIn         <= busMasterDataOut (0);
                busMasterAcknowledgeIn  <= (0 => iBusSlaveAcknowledgeOut, others => '0');
            -- [[[cog
            -- tmpl = """
            -- elsif (busMasterGranted({i}) = '1') then
            --     iBusSlaveStrobeIn       <= busMasterStrobeOut ({i});
            --     iBusSlaveAddressIn      <= busMasterAddressOut ({i});
            --     iBusSlaveByteEnableIn   <= busMasterByteEnableOut ({i});
            --     iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut ({i});
            --     iBusSlaveOriginalPortIn <= x"ff";
            --     iBusSlaveDataIn         <= (others => '0');
            --     busMasterAcknowledgeIn  <= ({i}      => iBusSlaveAcknowledgeOut, others => '0');
            -- """.strip()
            -- for i in range(1, int(nports) + 1):
            --   print(tmpl.format(i = i))
            -- ]]]
            elsif (busMasterGranted(1) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (1);
                iBusSlaveAddressIn      <= busMasterAddressOut (1);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (1);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (1);
                iBusSlaveOriginalPortIn <= x"ff";
                iBusSlaveDataIn         <= (others => '0');
                busMasterAcknowledgeIn  <= (1      => iBusSlaveAcknowledgeOut, others => '0');
            elsif (busMasterGranted(2) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (2);
                iBusSlaveAddressIn      <= busMasterAddressOut (2);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (2);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (2);
                iBusSlaveOriginalPortIn <= x"ff";
                iBusSlaveDataIn         <= (others => '0');
                busMasterAcknowledgeIn  <= (2      => iBusSlaveAcknowledgeOut, others => '0');
            elsif (busMasterGranted(3) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (3);
                iBusSlaveAddressIn      <= busMasterAddressOut (3);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (3);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (3);
                iBusSlaveOriginalPortIn <= x"ff";
                iBusSlaveDataIn         <= (others => '0');
                busMasterAcknowledgeIn  <= (3      => iBusSlaveAcknowledgeOut, others => '0');
            elsif (busMasterGranted(4) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (4);
                iBusSlaveAddressIn      <= busMasterAddressOut (4);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (4);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (4);
                iBusSlaveOriginalPortIn <= x"ff";
                iBusSlaveDataIn         <= (others => '0');
                busMasterAcknowledgeIn  <= (4      => iBusSlaveAcknowledgeOut, others => '0');
            elsif (busMasterGranted(5) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (5);
                iBusSlaveAddressIn      <= busMasterAddressOut (5);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (5);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (5);
                iBusSlaveOriginalPortIn <= x"ff";
                iBusSlaveDataIn         <= (others => '0');
                busMasterAcknowledgeIn  <= (5      => iBusSlaveAcknowledgeOut, others => '0');
            elsif (busMasterGranted(6) = '1') then
                iBusSlaveStrobeIn       <= busMasterStrobeOut (6);
                iBusSlaveAddressIn      <= busMasterAddressOut (6);
                iBusSlaveByteEnableIn   <= busMasterByteEnableOut (6);
                iBusSlaveWriteEnableIn  <= busMasterWriteEnableOut (6);
                iBusSlaveOriginalPortIn <= x"ff";
                iBusSlaveDataIn         <= (others => '0');
                busMasterAcknowledgeIn  <= (6      => iBusSlaveAcknowledgeOut, others => '0');
            -- [[[end]]]
            else
                iBusSlaveStrobeIn            <= busMasterUserStrobeIn;
                iBusSlaveAddressIn           <= busMasterUserAddressIn;
                iBusSlaveByteEnableIn        <= busMasterUserByteEnableIn;
                iBusSlaveWriteEnableIn       <= busMasterUserWriteEnableIn;
                iBusSlaveOriginalPortIn      <= x"ff";
                iBusSlaveDataIn              <= busMasterUserDataIn;
                iBusMasterUserAcknowledgeOut <= iBusSlaveAcknowledgeOut;
                busMasterAcknowledgeIn       <= (others => '0');
            end if;

            busSlaveDataOut             <= ibusMasterDataOut;
            busMasterUserDataOut        <= ibusMasterDataOut;
            busMasterUserAcknowledgeOut <= iBusMasterUserAcknowledgeOut;
        end if;
    end process;

--------------------------------------------------------------------------------
-- time code forwarding logic.
--------------------------------------------------------------------------------
    timeCodeControl : entity work.SpaceWireRouterIPTimeCodeControl6
        port map (
            clock                 => clock,
            reset                 => reset,
            -- switch info.
            linkUp                => iLinkUp,
            receiveTimeCode       => routerTimeCode,
            -- spacewire timecode.
            -- [[[cog
            -- tmpl = """
            -- port{i}TimeCodeEnable   => transmitTimeCodeEnable ({i}),
            -- port{i}TickIn           => port{i}TickIn,
            -- port{i}TimeCodeIn       => port{i}TiemCodeIn,
            -- port{i}TickOut          => port{i}TickOut,
            -- port{i}TimeCodeOut      => port{i}TimeCodeOut,
            -- """.strip()
            -- for i in range(1, int(nports) + 1):
            --   print(tmpl.format(i = i))
            -- ]]]
            port1TimeCodeEnable   => transmitTimeCodeEnable (1),
            port1TickIn           => port1TickIn,
            port1TimeCodeIn       => port1TiemCodeIn,
            port1TickOut          => port1TickOut,
            port1TimeCodeOut      => port1TimeCodeOut,
            port2TimeCodeEnable   => transmitTimeCodeEnable (2),
            port2TickIn           => port2TickIn,
            port2TimeCodeIn       => port2TiemCodeIn,
            port2TickOut          => port2TickOut,
            port2TimeCodeOut      => port2TimeCodeOut,
            port3TimeCodeEnable   => transmitTimeCodeEnable (3),
            port3TickIn           => port3TickIn,
            port3TimeCodeIn       => port3TiemCodeIn,
            port3TickOut          => port3TickOut,
            port3TimeCodeOut      => port3TimeCodeOut,
            port4TimeCodeEnable   => transmitTimeCodeEnable (4),
            port4TickIn           => port4TickIn,
            port4TimeCodeIn       => port4TiemCodeIn,
            port4TickOut          => port4TickOut,
            port4TimeCodeOut      => port4TimeCodeOut,
            port5TimeCodeEnable   => transmitTimeCodeEnable (5),
            port5TickIn           => port5TickIn,
            port5TimeCodeIn       => port5TiemCodeIn,
            port5TickOut          => port5TickOut,
            port5TimeCodeOut      => port5TimeCodeOut,
            port6TimeCodeEnable   => transmitTimeCodeEnable (6),
            port6TickIn           => port6TickIn,
            port6TimeCodeIn       => port6TiemCodeIn,
            port6TickOut          => port6TickOut,
            port6TimeCodeOut      => port6TimeCodeOut,
            -- [[[end]]]
--
            autoTimeCodeValue     => autoTimeCodeValue,
            autoTimeCodeCycleTime => autoTimeCodeCycleTime
            );

end behavioral;

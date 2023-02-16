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


entity SpaceWireRouterIPRMAPPort is
    generic (
        gPortNumber           : std_logic_vector (7 downto 0);
        gNumberOfExternalPort : std_logic_vector (7 downto 0));
    port (
        clock                   : in  std_logic;
        reset                   : in  std_logic;
        -- switch info.
        -- [[[cog
        -- print(f"linkUp                  : in  std_logic_vector ({n-1} downto 0);");
        -- ]]]
        linkUp                  : in  std_logic_vector (6 downto 0);
        -- [[[end]]]
        timeOutEnable           : in  std_logic;
        timeOutCountValue       : in  std_logic_vector (19 downto 0);
        timeOutEEPOut           : out std_logic;
        timeOutEEPIn            : in  std_logic;
        packetDropped           : out std_logic;
        -- switch out port.
        PortRequest             : out std_logic;
        destinationPortOut      : out std_logic_vector (7 downto 0);
        sorcePortOut            : out std_logic_vector (7 downto 0);
        grantedIn               : in  std_logic;
        dataOut                 : out std_logic_vector (8 downto 0);
        strobeOut               : out std_logic;
        readyIn                 : in  std_logic;
        -- switch in port.
        requestIn               : in  std_logic;
        sourcePortIn            : in  std_logic_vector (7 downto 0);
        dataIn                  : in  std_logic_vector (8 downto 0);
        strobeIn                : in  std_logic;
        readyOut                : out std_logic;
        --
        logicalAddress          : in  std_logic_vector (7 downto 0);
        rmapKey                 : in  std_logic_vector (7 downto 0);
        crcRevision             : in  std_logic;
        -- table read/write i/f.
        busMasterOriginalPort   : out std_logic_vector (7 downto 0);
        busMasterAddressOut     : out std_logic_vector (31 downto 0);
        busMasterDataIn         : in  std_logic_vector (31 downto 0);
        busMasterDataOut        : out std_logic_vector (31 downto 0);
        busMasterWriteEnableOut : out std_logic;
        busMasterStrobeOut      : out std_logic;
        busMasterByteEnableOut  : out std_logic_vector (3 downto 0);
        busMasterRequestOut     : out std_logic;
        busMasterAcknowledgeIn  : in  std_logic
        );
end SpaceWireRouterIPRMAPPort;


architecture behavioral of SpaceWireRouterIPRMAPPort is

    signal iRMAPStrobeIn     : std_logic;
    signal busMasterCycleOut : std_logic;
    signal destinationPort   : std_logic_vector (7 downto 0);
    
begin
    
    iRMAPStrobeIn <= requestIn and strobeIn;

    RMAPTargetDecoder : entity work.SpaceWireRouterIPRMAPDecoder
        port map (
            clock => clock,
            reset => reset,

            logicalAddress          => logicalAddress,
            rmapKey                 => rmapKey,
            crcRevision             => crcRevision,
--
            linkUP                  => linkUp,
--
            timeOutEnable           => timeOutEnable,
            timeOutCountValue       => timeOutCountValue,
            timeOutEEPOut           => timeOutEEPOut,
            timeOutEEPIn            => timeOutEEPIn,
            packetDropped           => packetDropped,
--
            requestOut              => PortRequest,
            grantedIn               => grantedIn,
            dataOut                 => dataOut,
            strobeOut               => strobeOut,
            readyIn                 => readyIn,
--
            strobeIn                => iRMAPStrobeIn,
            dataIn                  => dataIn,
            readyOut                => readyOut,
--
            sourcePortIn            => sourcePortIn,
            destinationPortOut      => destinationPort,
--
            busMasterAddressOut     => busMasterAddressOut,
            busMasterByteEnableOut  => busMasterByteEnableOut,
            busMasterDataOut        => busMasterDataOut,
            busMasterDataIn         => busMasterDataIn,
            busMasterWriteEnableOut => busMasterWriteEnableOut,
            busMasterCycleOut       => busMasterCycleOut,
            busMasterAcknowledgeIn  => busMasterAcknowledgeIn
            );

    busMasterStrobeOut    <= busMasterCycleOut;
    busMasterRequestOut   <= busMasterCycleOut;
    busMasterOriginalPort <= destinationPort;
    destinationPortOut    <= destinationPort;
    sorcePortOut          <= gPortNumber;
    
    
end behavioral;


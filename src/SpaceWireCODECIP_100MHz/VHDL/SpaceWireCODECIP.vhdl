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

use work.SpaceWireCODECIPPackage.all;
use work.testlib.all;

entity SpaceWireCODECIP is
  generic (
    clkfreq   : real;
    txclkfreq : real;
    tech      : integer);
  port (
    clock                       : in  std_logic;
    transmitClock               : in  std_logic;
    receiveClock                : in  std_logic;
    reset                       : in  std_logic;
--
    transmitFIFOWriteEnable     : in  std_logic;
    transmitFIFODataIn          : in  std_logic_vector(8 downto 0);
    transmitFIFOFull            : out std_logic;
    transmitFIFODataCount       : out std_logic_vector(5 downto 0);
    receiveFIFOReadEnable       : in  std_logic;
    receiveFIFODataOut          : out std_logic_vector(8 downto 0);
    receiveFIFOFull             : out std_logic;
    receiveFIFOEmpty            : out std_logic;
    receiveFIFODataCount        : out std_logic_vector(5 downto 0);
--
    tickIn                      : in  std_logic;
    timeIn                      : in  std_logic_vector(5 downto 0);
    controlFlagsIn              : in  std_logic_vector(1 downto 0);
    tickOut                     : out std_logic;
    timeOut                     : out std_logic_vector(5 downto 0);
    controlFlagsOut             : out std_logic_vector(1 downto 0);
--
    linkStart                   : in  std_logic;
    linkDisable                 : in  std_logic;
    autoStart                   : in  std_logic;
    linkStatus                  : out std_logic_vector(15 downto 0);
    errorStatus                 : out std_logic_vector(7 downto 0);
    transmitClockDivideValue    : in  std_logic_vector(5 downto 0);
    creditCount                 : out std_logic_vector(5 downto 0);
    outstandingCount            : out std_logic_vector(5 downto 0);
--
    transmitActivity            : out std_logic;
    receiveActivity             : out std_logic;
--
    spaceWireDataOut            : out std_logic;
    spaceWireStrobeOut          : out std_logic;
    spaceWireDataIn             : in  std_logic;
    spaceWireStrobeIn           : in  std_logic;
--
    statisticalInformationClear : in  std_logic;
    statisticalInformation      : out bit32X8Array;
        testen                      : in  std_logic;
        tmi                         : in  memdbg_in_t;
        tmo                         : out memdbg_out_t;
        rmi                         : in  memdbg_in_t;
        rmo                         : out memdbg_out_t
    );
end SpaceWireCODECIP;

architecture Behavioral of SpaceWireCODECIP is
  -- gDisconnectCountValue = transmitClock period * gDisconnectCountValue = 850ns.
  constant gDisconnectCountValue               : integer range 0 to 255        := integer(850.0e-9 * txclkfreq);

  -- gTimer6p4usValue = Clock period * gTimer6p4usValue = 6.4us.
  constant gTimer6p4usValue                    : integer := integer(6.4e-6 * clkfreq);

  -- gTimer12p8usValue = Clock period * gTimer12p8usValue = 12.8us.
  constant gTimer12p8usValue                   : integer := integer(12.8e-6 * clkfreq);

  -- gInitializeTransmitClockDivideValue = transmitClock frequency / (gInitializeTransmitClockDivideValue + 1) = 10MHz.
  constant gInitializeTransmitClockDivideValue : integer := integer(clkfreq / 10.0e6 - 1.0);

  signal iTransmitBusy            : std_logic;
  signal transmitBusySynchronized : std_logic;

  type transmitterWriteStateMachine is (
    transmitterWriteStateIdle,
    transmitterWriteStateWrite0,
    transmitterWriteStateWrite1,
    transmitterWriteStateReset0,
    transmitterWriteStateReset1,
    transmitterWriteStateReset2
    );
  signal transmitterWriteState              : transmitterWriteStateMachine;
  -- transmitter.
  signal iTransmitDataEnable                : std_logic;
  signal iTransmitData                      : std_logic_vector (7 downto 0);
  signal iTransmitDataControlFlag           : std_logic;
  signal transmitReady                      : std_logic;
  -- receiver.
  signal receiveFIFOWriteEnable1            : std_logic;
  signal receiveData                        : std_logic_vector (7 downto 0);
  signal receiveDataControlFlag             : std_logic;
  signal receiveFIFOCount                   : std_logic_vector(5 downto 0);
  signal iTransmitFIFOReadEnable            : std_logic;
  signal transmitFIFOEmpty                  : std_logic;
  signal transmitFIFOReadData               : std_logic_vector (8 downto 0);
  signal iReceiveFIFOWriteData              : std_logic_vector (8 downto 0);
  signal iReceiveFIFOWriteEnable2           : std_logic;
  signal iSpaceWireResetOut                 : std_logic;
  signal iResetReceiveFIFO                  : std_logic;
  signal iMiddleOfTransmitPacket            : std_logic;
  signal iMiddleOfReceivePacket             : std_logic;
  signal iMiddleOfReceivePacketSynchronized : std_logic;
  signal iFIFOAvailable                     : std_logic;
  signal iReceiveFIFOWriteEEP               : std_logic;

begin

  iTransmitData            <= transmitFIFOReadData (7 downto 0);
  iTransmitDataControlFlag <= transmitFIFOReadData (8);

  transmitActivity <= iTransmitFIFOReadEnable;
  receiveActivity  <= receiveFIFOWriteEnable1;

--------------------------------------------------------------------------------
--  FIFO.
--------------------------------------------------------------------------------
  transmitFIFO : entity work.SpaceWireCODECIPFIFO9x64
    generic map (
        tech => tech
    )
    port map (
      reset          => reset,
      writeClock     => clock,
      readClock      => clock,
      writeDataIn    => transmitFIFODataIn,
      writeEnable    => transmitFIFOWriteEnable,
      readEnable     => iTransmitFIFOReadEnable,
      readDataOut    => transmitFIFOReadData,
      empty          => transmitFIFOEmpty,
      full           => transmitFIFOFull,
      readDataCount  => transmitFIFODataCount,
      writeDataCount => open,
            testen         => testen,
            mi             => tmi,
            mo             => tmo
      );

  receiveFIFO : entity work.SpaceWireCODECIPFIFO9x64
    generic map (
        tech => tech
    )
    port map (
      reset          => reset,
      writeClock     => receiveClock,
      readClock      => clock,
      writeDataIn    => iReceiveFIFOWriteData,
      writeEnable    => iReceiveFIFOWriteEnable2,
      readEnable     => receiveFIFOReadEnable,
      readDataOut    => receiveFIFODataOut,
      empty          => receiveFIFOEmpty,
      full           => receiveFIFOFull,
      readDataCount  => receiveFIFOCount,
      writeDataCount => open,
            testen         => testen,
            mi             => rmi,
            mo             => rmo
      );

  transmitReadyPulse : entity work.SpaceWireCODECIPSynchronizeOnePulse
    port map (
      clock             => clock,
      reset             => reset,
      asynchronousIn    => iTransmitBusy,
      synchronizedOut   => transmitBusySynchronized
      );

  SpaceWireLinkInterface : entity work.SpaceWireCODECIPLinkInterface
    generic map (
      gDisconnectCountValue     => gDisconnectCountValue,
      gTimer6p4usValue          => gTimer6p4usValue,
      gTimer12p8usValue         => gTimer12p8usValue,
      gTransmitClockDivideValue => gInitializeTransmitClockDivideValue
      )
    port map (
      clock                       => clock,
      reset                       => reset,
      -- state machine.
      transmitClock               => transmitClock,
      linkStart                   => linkStart,
      linkDisable                 => linkDisable,
      autoStart                   => autoStart,
      linkStatus                  => linkStatus,
      errorStatus                 => errorStatus,
      spaceWireResetOut           => iSpaceWireResetOut,
      FIFOAvailable               => iFIFOAvailable,
      -- transmitter.
      tickIn                      => tickIn,
      timeIn                      => timeIn,
      controlFlagsIn              => controlFlagsIn,
      transmitDataEnable          => iTransmitDataEnable,
      transmitData                => iTransmitData,
      transmitDataControlFlag     => iTransmitDataControlFlag,
      transmitReady               => transmitReady,
      transmitClockDivideValue    => transmitClockDivideValue,
      creditCount                 => creditCount,
      outstndingCount             => outstandingCount,
      -- receiver.
      receiveClock                => receiveClock,
      tickOut                     => tickOut,
      timeOut                     => timeOut,
      controlFlagsOut             => controlFlagsOut,
      receiveFIFOWriteEnable1     => receiveFIFOWriteEnable1,
      receiveData                 => receiveData,
      receiveDataControlFlag      => receiveDataControlFlag,
      receiveFIFOCount            => receiveFIFOCount,
      -- serial i/o.
      spaceWireDataOut            => spaceWireDataOut,
      spaceWireStrobeOut          => spaceWireStrobeOut,
      spaceWireDataIn             => spaceWireDataIn,
      spaceWireStrobeIn           => spaceWireStrobeIn,
      statisticalInformationClear => statisticalInformationClear,
      statisticalInformation      => statisticalInformation
      );

  iReceiveFIFOWriteData <= "100000001" when iReceiveFIFOWriteEEP = '1' else receiveDataControlFlag & receiveData;

  iReceiveFIFOWriteEnable2 <= receiveFIFOWriteEnable1 or iReceiveFIFOWriteEEP;
  receiveFIFODataCount     <= receiveFIFOCount;
  iFIFOAvailable           <= '0' when (iMiddleOfTransmitPacket = '1' or iMiddleOfReceivePacketSynchronized = '1') else '1';
  iTransmitBusy            <= not transmitReady;

----------------------------------------------------------------------
-- ECSS-E-ST-50-12C 11.4  Link error recovery.
-- If previous character was NOT EOP, then add EEP (error end of
-- packet) to the receiver buffer, when detect Error(SpaceWireReset) while
-- receiving the Receive packet.
----------------------------------------------------------------------
  process (receiveClock, reset)
  begin
    if (reset = '1') then
      iMiddleOfReceivePacket <= '0';
      iReceiveFIFOWriteEEP   <= '0';
      iResetReceiveFIFO      <= '0';
    elsif (receiveClock'event and receiveClock = '1') then
      if (iSpaceWireResetOut = '1') then
        iResetReceiveFIFO <= '1';
      else
        iResetReceiveFIFO <= '0';
      end if;

      if (iResetReceiveFIFO = '1') then
        if (iMiddleOfReceivePacket = '1') then
          iMiddleOfReceivePacket <= '0';
          iReceiveFIFOWriteEEP   <= '1';
        else
          iReceiveFIFOWriteEEP <= '0';
        end if;
      elsif (receiveFIFOWriteEnable1 = '1') then
        if (iReceiveFIFOWriteData (8) = '1') then
          iMiddleOfReceivePacket <= '0';
        else
          iMiddleOfReceivePacket <= '1';
        end if;
      end if;
    end if;
  end process;

----------------------------------------------------------------------
-- ECSS-E-ST-50-12C 11.4 Link error recovery.
-- Delete data in the  transmitter buffer until the next EOP,
-- when detect  Error (SpaceWireReset) while sending
-- the Receive packet
----------------------------------------------------------------------
  process (clock, reset)
  begin
    if (reset = '1') then
      iTransmitDataEnable     <= '0';
      iTransmitFIFOReadEnable <= '0';
      iMiddleOfTransmitPacket <= '0';
      transmitterWriteState   <= transmitterWriteStateIdle;

    elsif (clock'event and clock = '1') then
      case transmitterWriteState is
        when transmitterWriteStateIdle =>
          if (iSpaceWireResetOut = '1' and iMiddleOfTransmitPacket = '1') then
            transmitterWriteState <= transmitterWriteStateReset0;
          else
            if (transmitFIFOEmpty = '0' and transmitReady = '1') then
              iTransmitFIFOReadEnable <= '1';
              transmitterWriteState   <= transmitterWriteStateWrite0;
            end if;
          end if;

        when transmitterWriteStateWrite0 =>
          iTransmitDataEnable     <= '1';
          iTransmitFIFOReadEnable <= '0';
          transmitterWriteState   <= transmitterWriteStateWrite1;

        when transmitterWriteStateWrite1 =>
          iTransmitDataEnable <= '0';
          if (iSpaceWireResetOut = '1') then
            if (transmitFIFOReadData (8) = '1') then
              iMiddleOfTransmitPacket <= '0';
              transmitterWriteState   <= transmitterWriteStateIdle;
            else
              iMiddleOfTransmitPacket <= '1';
              transmitterWriteState   <= transmitterWriteStateReset0;
            end if;
          else
            if (transmitBusySynchronized = '1') then
              if (transmitFIFOReadData (8) = '1') then
                iMiddleOfTransmitPacket <= '0';
              else
                iMiddleOfTransmitPacket <= '1';
              end if;
              transmitterWriteState <= transmitterWriteStateIdle;
            end if;
          end if;

        when transmitterWriteStateReset0 =>
          if (transmitFIFOEmpty = '0') then
            iTransmitFIFOReadEnable <= '1';
            transmitterWriteState   <= transmitterWriteStateReset1;
          end if;

        when transmitterWriteStateReset1 =>
          iTransmitFIFOReadEnable <= '0';
          transmitterWriteState   <= transmitterWriteStateReset2;

        when transmitterWriteStateReset2 =>
          if (transmitFIFOReadData (8) = '1') then
            iMiddleOfTransmitPacket <= '0';
            transmitterWriteState   <= transmitterWriteStateIdle;
          else
            iMiddleOfTransmitPacket <= '1';
            transmitterWriteState   <= transmitterWriteStateReset0;
          end if;
        --when others => null;
      end case;
    end if;

  end process;

----------------------------------------------------------------------
-- synchronize the Receive data receiving signal and the SystemClock.
----------------------------------------------------------------------
  process (clock, reset)
  begin
    if (reset = '1') then
      iMiddleOfReceivePacketSynchronized <= '0';
    elsif (clock'event and clock = '1') then
      if (iMiddleOfReceivePacket = '1') then
        iMiddleOfReceivePacketSynchronized <= '1';
      else
        iMiddleOfReceivePacketSynchronized <= '0';
      end if;
    end if;
  end process;

end Behavioral;

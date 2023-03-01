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

use work.SpaceWireCODECIPPackage.all;


entity SpaceWireCODECIPLinkInterface is
    generic (
        gDisconnectCountValue     : integer;
        gTimer6p4usValue          : integer;
        gTimer12p8usValue         : integer;
        gTransmitClockDivideValue : integer
        );
    port (
        clock                       : in  std_logic;
        reset                       : in  std_logic;
        -- state machine.
        transmitClock               : in  std_logic;
        linkStart                   : in  std_logic;
        linkDisable                 : in  std_logic;
        autoStart                   : in  std_logic;
        linkStatus                  : out std_logic_vector (15 downto 0);
        errorStatus                 : out std_logic_vector (7 downto 0);
        spaceWireResetOut           : out std_logic;
        FIFOAvailable               : in  std_logic;
        -- transmitter.
        tickIn                      : in  std_logic;
        timeIn                      : in  std_logic_vector (5 downto 0);
        controlFlagsIn              : in  std_logic_vector (1 downto 0);
        transmitDataEnable          : in  std_logic;
        transmitData                : in  std_logic_vector (7 downto 0);
        transmitDataControlFlag     : in  std_logic;
        transmitReady               : out std_logic;
        transmitClockDivideValue    : in  std_logic_vector(5 downto 0);
        creditCount                 : out std_logic_vector (5 downto 0);
        outstndingCount             : out std_logic_vector (5 downto 0);
        -- receiver.
        receiveClock                : in  std_logic;
        tickOut                     : out std_logic;
        timeOut                     : out std_logic_vector (5 downto 0);
        controlFlagsOut             : out std_logic_vector (1 downto 0);
        receiveFIFOWriteEnable1     : out std_logic;
        receiveData                 : out std_logic_vector (7 downto 0);
        receiveDataControlFlag      : out std_logic;
        receiveFIFOCount            : in  std_logic_vector(5 downto 0);
        -- serial i/o.
        spaceWireDataOut            : out std_logic;
        spaceWireStrobeOut          : out std_logic;
        spaceWireDataIn             : in  std_logic;
        spaceWireStrobeIn           : in  std_logic;
        statisticalInformationClear : in  std_logic;
        statisticalInformation      : out bit32X8Array
        );
end SpaceWireCODECIPLinkInterface;


architecture Behavioral of SpaceWireCODECIPLinkInterface is

    signal gotFCT                        : std_logic;
    signal gotTimeCode                   : std_logic;
    signal gotNCharacter                 : std_logic;
    signal gotNull                       : std_logic;
    signal iGotBit                       : std_logic;
    signal iCreditError                  : std_logic;
    signal parityError                   : std_logic;
    signal escapeError                   : std_logic;
    signal disconnectError               : std_logic;
    signal receiveError                  : std_logic;
    signal enableReceive                 : std_logic;
    signal sendNCharactors               : std_logic;
    signal sendTimeCode                  : std_logic;
    signal after12p8us                   : std_logic;
    signal after6p4us                    : std_logic;
    signal enableTransmit                : std_logic;
    signal sendNulls                     : std_logic;
    signal sendFCTs                      : std_logic;
    signal spaceWireResetOutSignal       : std_logic;
    signal characterSequenceError        : std_logic;
    signal timer6p4usReset               : std_logic;
    signal timer12p8usStart              : std_logic;
    signal receiveFIFOWriteEnable0       : std_logic;
    signal iReceiveFIFOWriteEnable1      : std_logic;
    signal receiveOff                    : std_logic;
    signal receiveTimeCodeOut            : std_logic_vector(7 downto 0) := x"00";
    signal linkUpTransitionSynchronize   : std_logic;
    signal linkDownTransitionSynchronize : std_logic;
    signal linkUpEnable                  : std_logic;
    signal nullSynchronize               : std_logic;
    signal fctSynchronize                : std_logic;
    signal receiveEEPAsynchronous        : std_logic;
    signal receiveEOPAsynchronous        : std_logic;
    signal receiveByteAsynchronous       : std_logic;
    signal transmitEEPAsynchronous       : std_logic;
    signal transmitEOPAsynchronous       : std_logic;
    signal transmitByteAsynchronous      : std_logic;
    signal characterMonitor              : std_logic_vector(6 downto 0);

begin


    spaceWireReceiver : entity work.SpaceWireCODECIPReceiverSynchronize
        generic map (
            gDisconnectCountValue => gDisconnectCountValue
            )
        port map (
            receiveClock               => receiveClock,
            spaceWireDataIn            => spaceWireDataIn,
            spaceWireStrobeIn          => spaceWireStrobeIn,
            receiveDataOut(7 downto 0) => receiveData,
            receiveDataOut(8)          => receiveDataControlFlag,
            receiveDataValidOut        => receiveByteAsynchronous,
            receiveTimeCodeOut         => receiveTimeCodeOut,
            receiveFIFOWriteEnable     => receiveFIFOWriteEnable0,
            receiveFCTOut              => gotFCT,
            receiveTimeCodeValidOut    => gotTimeCode,
            receiveNCharacterOut       => gotNCharacter,
            receiveNullOut             => gotNull,
            receiveEEPOut              => receiveEEPAsynchronous,
            receiveEOPOut              => receiveEOPAsynchronous,
            receiveOffOut              => receiveOff,
            receiverErrorOut           => receiveError,
            parityErrorOut             => parityError,
            escapeErrorOut             => escapeError,
            disconnectErrorOut         => disconnectError,
            enableReceive              => enableReceive,
            spaceWireReset             => spaceWireResetOutSignal
            );



    spaceWireTransmitter : entity work.SpaceWireCODECIPTransmitter
        generic map (
            gInitializeTransmitClockDivideValue => gTransmitClockDivideValue
            )
        port map (
            transmitClock            => transmitClock,
            clock                    => clock,
            receiveClock             => receiveClock,
            reset                    => reset,
            spaceWireDataOut         => spaceWireDataOut,
            spaceWireStrobeOut       => spaceWireStrobeOut,
            tickIn                   => tickIn,
            timeIn                   => timeIn,
            controlFlagsIn           => controlFlagsIn,
            transmitDataEnable       => transmitDataEnable,
            transmitData             => transmitData,
            transmitDataControlFlag  => transmitDataControlFlag,
            transmitReady            => transmitReady,
            enableTransmit           => enableTransmit,
            --autoStart.
            sendNulls                => sendNulls,
            sendFCTs                 => sendFCTs,
            sendNCharacters          => sendNCharactors,
            sendTimeCodes            => sendTimeCode,
            --tx_fct.
            gotFCT                   => gotFCT,
            gotNCharacter            => gotNCharacter,
            receiveFIFOCount         => receiveFIFOCount,
            creditError              => iCreditError,
            transmitClockDivide      => transmitClockDivideValue,
            creditCountOut           => creditCount,
            outstandingCountOut      => outstndingCount,
            spaceWireResetOut        => spaceWireResetOutSignal,
            transmitEEPAsynchronous  => transmitEEPAsynchronous,
            TransmitEOPAsynchronous  => transmitEOPAsynchronous,
            TransmitByteAsynchronous => transmitByteAsynchronous
            );


    spaceWireStateMachine : entity work.SpaceWireCODECIPStateMachine
        port map (
            clock                         => clock,
            receiveClock                  => receiveClock,
            reset                         => reset,
            after12p8us                   => after12p8us,
            after6p4us                    => after6p4us,
            linkStart                     => linkStart,
            linkDisable                   => linkDisable,
            autoStart                     => autoStart,
            enableTransmit                => enableTransmit,
            sendNulls                     => sendNulls,
            sendFCTs                      => sendFCTs,
            sendNCharacter                => sendNCharactors,
            sendTimeCodes                 => sendTimeCode,
            gotFCT                        => gotFCT,
            gotTimeCode                   => gotTimeCode,
            gotNCharacter                 => gotNCharacter,
            gotNull                       => gotNull,
            gotBit                        => iGotBit,
            creditError                   => iCreditError,
            receiveError                  => receiveError,
            enableReceive                 => enableReceive,
            characterSequenceError        => characterSequenceError,
            spaceWireResetOut             => spaceWireResetOutSignal,
            FIFOAvailable                 => FIFOAvailable,
            timer6p4usReset               => timer6p4usReset,
            timer12p8usStart              => timer12p8usStart,
            linkUpTransitionSynchronize   => linkUpTransitionSynchronize,
            linkDownTransitionSynchronize => linkDownTransitionSynchronize,
            linkUpEnable                  => linkUpEnable,
            nullSynchronize               => nullSynchronize,
            fctSynchronize                => fctSynchronize
            );

    spaceWireTimer : entity work.SpaceWireCODECIPTimer
        generic map (
            gTimer6p4usValue  => gTimer6p4usValue,
            gTimer12p8usValue => gTimer12p8usValue
            )
        port map (
            clock            => clock,
            reset            => reset,
            timer6p4usReset  => timer6p4usReset,
            timer12p8usStart => timer12p8usStart,
            after6p4us       => after6p4us,
            after12p8us      => after12p8us
            );

    spaceWireStatisticalInformationCount : entity work.SpaceWireCODECIPStatisticalInformationCount
        port map (
            clock                       => clock,
            reset                       => reset,
            statisticalInformationClear => statisticalInformationClear,
            transmitClock               => transmitClock,
            receiveClock                => receiveClock,
            receiveEEPAsynchronous      => receiveEEPAsynchronous,
            receiveEOPAsynchronous      => receiveEOPAsynchronous,
            receiveByteAsynchronous     => receiveByteAsynchronous,
            transmitEEPAsynchronous     => transmitEEPAsynchronous,
            transmitEOPAsynchronous     => transmitEOPAsynchronous,
            transmitByteAsynchronous    => transmitByteAsynchronous,
            linkUpTransition            => linkUpTransitionSynchronize,
            linkDownTransition          => linkDownTransitionSynchronize,
            linkUpEnable                => linkUpEnable,
            nullSynchronous             => nullSynchronize,
            fctSynchronous              => fctSynchronize,
            statisticalInformation      => statisticalInformation,
            characterMonitor            => characterMonitor
            );


    SpaceWireTimeCodeControl : entity work.SpaceWireCODECIPTimeCodeControl
        port map (
            clock              => clock,
            reset              => reset,
            receiveClock       => receiveClock,
            gotTimeCode        => gotTimeCode,
            receiveTimeCodeOut => receiveTimeCodeOut,
            timeOut            => timeOut,
            controlFlagsOut    => controlFlagsOut,
            tickOut            => tickOut
            );


    receiveFIFOWriteEnable1  <= iReceiveFIFOWriteEnable1;
    iReceiveFIFOWriteEnable1 <= (receiveFIFOWriteEnable0 and sendNCharactors);
    iGotBit                  <= not receiveOff;
    spaceWireResetOut        <= spaceWireResetOutSignal;

----------------------------------------------------------------------
-- Define status signal as LinkStatus or ErrorStatus.
----------------------------------------------------------------------
    linkStatus (0)           <= enableTransmit;
    linkStatus (1)           <= enableReceive;
    linkStatus (2)           <= sendNulls;
    linkStatus (3)           <= sendFCTs;
    linkStatus (4)           <= sendNCharactors;
    linkStatus (5)           <= sendTimeCode;
    linkStatus (6)           <= '0';
    linkStatus (7)           <= spaceWireResetOutSignal;
    linkStatus (15 downto 8) <= "0" & characterMonitor;

    errorStatus (0) <= characterSequenceError;  --sequence.
    errorStatus (1) <= iCreditError;            --credit.
    errorStatus (2) <= receiveError;            --receiveError(=parity, discon or escape error)
    errorStatus (3) <= '0';
    errorStatus (4) <= parityError;             -- parity.
    errorStatus (5) <= disconnectError;         -- disconnect.
    errorStatus (6) <= escapeError;             -- escape.
    errorStatus (7) <= '0';

end Behavioral;

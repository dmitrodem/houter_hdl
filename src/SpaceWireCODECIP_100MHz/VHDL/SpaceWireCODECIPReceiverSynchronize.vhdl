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

entity SpaceWireCODECIPReceiverSynchronize is
    generic(
        gDisconnectCountValue : integer
    );
    port(
        spaceWireStrobeIn       : in  std_logic;
        spaceWireDataIn         : in  std_logic;
        receiveDataOut          : out std_logic_vector(8 downto 0);
        receiveDataValidOut     : out std_logic;
        receiveTimeCodeOut      : out std_logic_vector(7 downto 0);
        receiveTimeCodeValidOut : out std_logic;
        receiveNCharacterOut    : out std_logic;
        receiveFCTOut           : out std_logic;
        receiveNullOut          : out std_logic;
        receiveEEPOut           : out std_logic;
        receiveEOPOut           : out std_logic;
        receiveOffOut           : out std_logic;
        receiverErrorOut        : out std_logic;
        parityErrorOut          : out std_logic;
        escapeErrorOut          : out std_logic;
        disconnectErrorOut      : out std_logic;
        spaceWireReset          : in  std_logic;
        receiveFIFOWriteEnable  : out std_logic;
        enableReceive           : in  std_logic;
        receiveClock            : in  std_logic
    );
end SpaceWireCODECIPReceiverSynchronize;

architecture RTL of SpaceWireCODECIPReceiverSynchronize is

    type spaceWireStateMachine is (
        ST_IDLE,
        ST_OFF,
        ST_EVEN0,
        ST_EVEN1,
        ST_EVEN_WAIT,
        ST_ODD0,
        ST_ODD1,
        ST_ODD_WAIT
    );

    type registers is record
        strobe_data          : std_logic_vector(1 downto 0);
        state                : spaceWireStateMachine;
        data_reg             : std_logic_vector(7 downto 0);
        parity               : std_logic;
        error_parity         : std_logic;
        link_timeout_counter : unsigned(15 downto 0);
        error_disconnect     : std_logic;
        flag_command         : std_logic;
        flag_data            : std_logic;
        bit_count            : unsigned(3 downto 0);
        timecode             : std_logic_vector(7 downto 0);
        rx_data              : std_logic_vector(8 downto 0);
        rx_write             : std_logic;
        rx_valid             : std_logic;
        timecode_valid       : std_logic;
        rx_null              : std_logic;
        rx_fct               : std_logic;
        rx_eop               : std_logic;
        rx_eep               : std_logic;
        error_esc            : std_logic;
        flag_esc             : std_logic;
    end record registers;

    constant RES_registers : registers := (
        strobe_data          => "00",
        state                => ST_IDLE,
        data_reg             => x"00",
        parity               => '0',
        error_parity         => '0',
        link_timeout_counter => (others => '0'),
        error_disconnect     => '0',
        flag_command         => '0',
        flag_data            => '0',
        bit_count            => (others => '0'),
        timecode             => (others => '0'),
        rx_data              => (others => '0'),
        rx_write             => '0',
        rx_valid             => '0',
        timecode_valid       => '0',
        rx_null              => '0',
        rx_fct               => '0',
        rx_eop               => '0',
        rx_eep               => '0',
        error_esc            => '0',
        flag_esc             => '0'
    );

    type registers_vector is array (natural range <>) of registers;

    signal r, rin     : registers;
    signal sd_p, sd_n : std_logic_vector(1 downto 0);

begin

    sync_p : process(receiveClock) is
    begin
        if (rising_edge(receiveClock)) then
            sd_p <= spaceWireStrobeIn & spaceWireDataIn;
        end if;
    end process sync_p;

    sync_n : process(receiveClock) is
    begin
        if (falling_edge(receiveClock)) then
            sd_n <= spaceWireStrobeIn & spaceWireDataIn;
        end if;
    end process sync_n;

    ----------------------------------------------------------------------
    -- ECSS-E-ST-50-12C 8.4.4 Receiver.
    ----------------------------------------------------------------------

    comb : process(r, enableReceive, spaceWireDataIn, spaceWireStrobeIn) is        
        variable v : registers;
    begin
        v := r;

        for i in 0 to 1 loop

            -- synchronize DS signal to the receiveClock
            v.strobe_data := spaceWireStrobeIn & spaceWireDataIn;

            if (enableReceive = '1') then
                -- Detect a change of the DS signal.
                if (r.state = ST_IDLE) then
                    if (r.strobe_data = "00") then
                        v.state := ST_OFF;
                    end if;
                elsif (r.state = ST_OFF) then
                    if (r.strobe_data = "10") then
                        v.state := ST_ODD0;
                    end if;
                elsif (r.state = ST_EVEN1 or r.state = ST_EVEN0 or r.state = ST_ODD_WAIT) then
                    if (r.strobe_data = "10") then
                        v.state := ST_ODD0;
                    elsif (r.strobe_data = "01") then
                        v.state := ST_ODD1;
                    else
                        v.state := ST_ODD_WAIT;
                    end if;
                elsif (r.state = ST_ODD1 or r.state = ST_ODD0 or r.state = ST_EVEN_WAIT) then
                    if (r.strobe_data = "00") then
                        v.state := ST_EVEN0;
                    elsif (r.strobe_data = "11") then
                        v.state := ST_EVEN1;
                    else
                        v.state := ST_EVEN_WAIT;
                    end if;
                else
                    v.state := ST_IDLE;
                end if;
            end if;

            -- Take the data into the shift register on the State transition of spaceWireState.
            if (enableReceive = '1') then
                if (r.state = ST_OFF) then
                    v.data_reg := RES_registers.data_reg;
                elsif (r.state = ST_ODD1 or r.state = ST_EVEN1) then
                    v.data_reg := '1' & r.data_reg(7 downto 1);
                elsif (r.state = ST_ODD0 or r.state = ST_EVEN0) then
                    v.data_reg := '0' & r.data_reg(7 downto 1);
                end if;
            else
                v.data_reg := RES_registers.data_reg;
            end if;

            ----------------------------------------------------------------------
            -- ECSS-E-ST-50-12C 7.4 Parity for error detection.
            -- Odd Parity.
            ----------------------------------------------------------------------
            if (enableReceive = '1' and r.error_esc = '0' and r.error_disconnect = '0') then
                if (r.state = ST_OFF) then
                    v.parity := '0';
                elsif (r.bit_count = 0 and r.state = ST_EVEN1) then
                    if (r.parity = '1') then
                        v.error_parity := '1';
                        v.parity       := '0';
                    end if;
                elsif (r.bit_count = 0 and r.state = ST_EVEN0) then
                    if r.parity = '0' then
                        v.error_parity := '1';
                    else
                        v.parity := '0';
                    end if;
                elsif (r.state = ST_ODD1 or r.state = ST_EVEN1) then
                    v.parity := not r.parity;
                end if;
            else
                v.error_parity := '0';
            end if;

            ----------------------------------------------------------------------
            -- ECSS-E-ST-50-12C 8.5.3.7.2 Disconnect error.
            -- Disconnect error is an error condition asserted
            -- when the length of time since the last transition on
            -- the D or S lines was longer than 850 ns nominal.
            ----------------------------------------------------------------------
            if (enableReceive = '1' and r.error_esc = '0' and r.error_parity = '0') then
                if (r.state = ST_ODD_WAIT or r.state = ST_EVEN_WAIT) then
                    if (r.link_timeout_counter < gDisconnectCountValue) then
                        v.link_timeout_counter := r.link_timeout_counter + 1;
                    else
                        v.error_disconnect := '1';
                    end if;
                elsif (r.state = ST_IDLE) then
                    v.link_timeout_counter := RES_registers.link_timeout_counter;
                elsif (r.state = ST_ODD1 or r.state = ST_EVEN1 or r.state = ST_ODD0 or r.state = ST_EVEN0) then
                    v.link_timeout_counter := RES_registers.link_timeout_counter;
                end if;
            else
                v.error_disconnect     := RES_registers.error_disconnect;
                v.link_timeout_counter := RES_registers.link_timeout_counter;
            end if;

            ----------------------------------------------------------------------
            -- ECSS-E-ST-50-12C 4.4 Character level
            -- ECSS-E-ST-50-12C 7.2 Data characters
            -- Discriminate the data character or the  the control character by the Data
            -- Control Flag.
            ----------------------------------------------------------------------
            if (enableReceive = '1') then
                if (r.state = ST_IDLE) then
                    v.flag_command := RES_registers.flag_command;
                    v.flag_data    := RES_registers.flag_data;
                elsif (r.bit_count = 0 and r.state = ST_EVEN0) then
                    v.flag_command := '0';
                    v.flag_data    := '1';
                elsif (r.bit_count = 0 and r.state = ST_EVEN1) then
                    v.flag_command := '1';
                    v.flag_data    := '0';
                end if;
            else
                v.flag_command := RES_registers.flag_command;
                v.flag_data    := RES_registers.flag_data;
            end if;

            ----------------------------------------------------------------------
            -- Increment bit of character corresponding by state transition of
            -- spaceWireState.
            ----------------------------------------------------------------------
            if (enableReceive = '1' and r.error_esc = '0' and r.error_disconnect = '0') then
                if (r.state = ST_IDLE or r.state = ST_OFF) then
                    v.bit_count := (others => '0');
                elsif (r.state = ST_EVEN1 or r.state = ST_EVEN0) then
                    if (r.bit_count = 1 and r.flag_command = '1') then
                        v.bit_count := (others => '0');
                    elsif (r.bit_count = 4 and r.flag_command = '0') then
                        v.bit_count := (others => '0');
                    else
                        v.bit_count := r.bit_count + 1;
                    end if;
                end if;
            else
                v.bit_count := RES_registers.bit_count;
            end if;

            ----------------------------------------------------------------------
            -- ECSS-E-ST-50-12C 7.3 Control characters and control codes.
            -- Discriminate  Data character, Control code and Time corde, and write to
            -- Receive buffer
            ----------------------------------------------------------------------
            if (enableReceive = '1') then
                if (r.bit_count = 0 and (r.state = ST_ODD0 or r.state = ST_ODD1)) then
                    if (r.flag_data = '1') then
                        if (r.flag_esc = '1') then
                            --Time Code Receive.
                            v.timecode := r.data_reg;
                        else
                            --Data Receive.
                            v.rx_data  := '0' & r.data_reg;
                            v.rx_write := '1';
                        end if;
                    elsif (r.flag_command = '1') then
                        if (r.data_reg(7 downto 6) = "10") then --EOP
                            v.rx_data := '1' & x"00";
                        elsif (r.data_reg(7 downto 6) = "01") then --EEP
                            v.rx_data := '1' & x"01";
                        end if;

                        if ((r.flag_esc /= '1') and (r.data_reg(7 downto 6) = "10" or r.data_reg(7 downto 6) = "01")) then
                            --EOP EEP Receive.
                            v.rx_write := '1';
                        end if;
                    end if;
                else
                    v.rx_write := '0';
                end if;
            end if;

            ----------------------------------------------------------------------
            -- ECSS-E-ST-50-12C 7.3 Control characters and control codes.
            -- ECSS-E-ST-50-12C 8.5.3.7.4 Escape error.
            -- Receive DataCharacter, ControlCode and TimeCode.
            ----------------------------------------------------------------------
            if (enableReceive = '1' and r.error_disconnect = '0' and r.error_parity = '0') then
                if (r.bit_count = 0 and (r.state = ST_ODD0 or r.state = ST_ODD1)) then
                    if (r.flag_command = '1') then
                        case r.data_reg(7 downto 6) is
                            ----------------------------------------------------------------------
                            -- ECSS-E-ST-50-12C 8.5.3.2 gotNULL.
                            -- ECSS-E-ST-50-12C 8.5.3.3 gotFCT.
                            ----------------------------------------------------------------------
                            when "00" => -- FCT Receive or Null Receive.
                                if (r.flag_esc = '1') then
                                    v.rx_null  := '1';
                                    v.flag_esc := '0';
                                else
                                    v.rx_fct := '1';
                                end if;

                            when "11" => -- ESC Receive.
                                if (r.flag_esc = '1') then
                                    v.error_esc := '1';
                                else
                                    v.flag_esc := '1';
                                end if;

                            when "10" => -- EOP Receive.
                                if (r.flag_esc = '1') then
                                    v.error_esc := '1';
                                else
                                    v.rx_eop := '1';
                                end if;

                            when "01" => -- EEP Receive.
                                if (r.flag_esc = '1') then
                                    v.error_esc := '1';
                                else
                                    v.rx_eep := '1';
                                end if;
                            when others => null;
                        end case;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-12C 8.5.3.5 gotTime-Code.
                    -- ECSS-E-ST-50-12C 8.5.3.4 gotN-Char.
                    ----------------------------------------------------------------------
                    elsif (r.flag_data = '1') then
                        if (r.flag_esc = '1') then -- TimeCode_Receive.
                            v.timecode_valid := '1';
                            v.flag_esc       := '0';
                        else            --N-Char_Receive.
                            v.rx_valid := '1';
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- Clear the previous Receive flag before receiving data.
                ----------------------------------------------------------------------
                elsif (r.bit_count = 1 and (r.state = ST_ODD0 or r.state = ST_ODD1)) then
                    v.rx_valid       := '0';
                    v.timecode_valid := '0';
                    v.rx_null        := '0';
                    v.rx_fct         := '0';
                    v.rx_eop         := '0';
                    v.rx_eep         := '0';
                elsif r.state = ST_IDLE then
                    v.rx_valid       := '0';
                    v.timecode_valid := '0';
                    v.rx_null        := '0';
                    v.rx_fct         := '0';
                    v.rx_eop         := '0';
                    v.rx_eep         := '0';
                    v.error_esc      := '0';
                    v.flag_esc       := '0';
                end if;
            else
                v.rx_valid       := '0';
                v.timecode_valid := '0';
                v.rx_null        := '0';
                v.rx_fct         := '0';
                v.rx_eop         := '0';
                v.rx_eep         := '0';
                v.error_esc      := '0';
                v.flag_esc       := '0';
            end if;

            if (r.error_disconnect = '1') then
                v.state := RES_registers.state;
            end if;
        end loop;
        rin <= v;
    end process comb;

    seq : process(receiveClock, spaceWireReset) is
    begin
        if (spaceWireReset = '1') then
            r <= RES_registers;
        elsif rising_edge(receiveClock) then
            r <= rin;
        end if;
    end process seq;

    receiveDataOut          <= r.rx_data;
    receiveTimeCodeOut      <= r.timecode;
    receiveTimeCodeValidOut <= r.timecode_valid;
    receiveNCharacterOut    <= (r.rx_eop or r.rx_eep or r.rx_valid);
    receiveFCTOut           <= r.rx_fct;
    receiveNullOut          <= r.rx_null;
    receiveOffOut           <= '1' when r.state = ST_OFF else '0';
    receiverErrorOut        <= (r.error_disconnect or r.error_parity or r.error_esc);
    receiveFIFOWriteEnable  <= r.rx_write;
    receiveDataValidOut     <= r.rx_valid;
    receiveEOPOut           <= r.rx_eop;
    receiveEEPOut           <= r.rx_eep;
    parityErrorOut          <= r.error_parity;
    escapeErrorOut          <= r.error_esc;
    disconnectErrorOut      <= r.error_disconnect;

end RTL;

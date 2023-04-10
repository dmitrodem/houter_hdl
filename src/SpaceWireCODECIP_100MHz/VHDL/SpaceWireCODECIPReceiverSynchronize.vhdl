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

    signal r, rin     : registers_vector (0 to 1);
    signal sd_p, sd_n, sd_f : std_logic_vector(1 downto 0);
    signal rs : registers;

    signal r_index, rin_index : integer range 0 to 1;

begin

    sync_p : process(receiveClock) is
    begin
        if (rising_edge(receiveClock)) then
            sd_p <= spaceWireStrobeIn & spaceWireDataIn;
            sd_n <= sd_f;
        end if;
    end process sync_p;

    sync_n : process(receiveClock) is
    begin
        if (falling_edge(receiveClock)) then
            sd_f <= spaceWireStrobeIn & spaceWireDataIn;
        end if;
    end process sync_n;

    ----------------------------------------------------------------------
    -- ECSS-E-ST-50-12C 8.4.4 Receiver.
    ----------------------------------------------------------------------

    comb : process(r, r_index, enableReceive, sd_n, sd_p) is
        variable vp, vn : registers;
        variable v_index : integer range 0 to 1;
        variable strobe_data : std_logic_vector (1 downto 0);
    begin
        v_index := r_index;

        for i in 0 to 1 loop
            if (i = 0) then
                vp := r(1);
            else
                vp := vn;
            end if;

            -- synchronize DS signal to the receiveClock
            if (i = 0) then
                strobe_data := sd_p;
            else
                strobe_data := sd_n;
            end if;

            if (enableReceive = '1') then
                -- Detect a change of the DS signal.
                if (vp.state = ST_IDLE) then
                    if (strobe_data = "00") then
                        vn.state := ST_OFF;
                    end if;
                elsif (vp.state = ST_OFF) then
                    if (strobe_data = "10") then
                        vn.state := ST_ODD0;
                    end if;
                elsif (vp.state = ST_EVEN1 or vp.state = ST_EVEN0 or vp.state = ST_ODD_WAIT) then
                    if (strobe_data = "10") then
                        vn.state := ST_ODD0;
                    elsif (strobe_data = "01") then
                        vn.state := ST_ODD1;
                    else
                        vn.state := ST_ODD_WAIT;
                    end if;
                elsif (vp.state = ST_ODD1 or vp.state = ST_ODD0 or vp.state = ST_EVEN_WAIT) then
                    if (strobe_data = "00") then
                        vn.state := ST_EVEN0;
                    elsif (strobe_data = "11") then
                        vn.state := ST_EVEN1;
                    else
                        vn.state := ST_EVEN_WAIT;
                    end if;
                else
                    vn.state := ST_IDLE;
                end if;
            end if;

            -- Take the data into the shift register on the State transition of spaceWireState.
            if (enableReceive = '1') then
                if (vp.state = ST_OFF) then
                    vn.data_reg := RES_registers.data_reg;
                elsif (vp.state = ST_ODD1 or vp.state = ST_EVEN1) then
                    vn.data_reg := '1' & vp.data_reg(7 downto 1);
                elsif (vp.state = ST_ODD0 or vp.state = ST_EVEN0) then
                    vn.data_reg := '0' & vp.data_reg(7 downto 1);
                end if;
            else
                vn.data_reg := RES_registers.data_reg;
            end if;

            ----------------------------------------------------------------------
            -- ECSS-E-ST-50-12C 7.4 Parity for error detection.
            -- Odd Parity.
            ----------------------------------------------------------------------
            if (enableReceive = '1' and vp.error_esc = '0' and vp.error_disconnect = '0') then
                if (vp.state = ST_OFF) then
                    vn.parity := '0';
                elsif (vp.bit_count = 0 and vp.state = ST_EVEN1) then
                    if (vp.parity = '1') then
                        vn.error_parity := '1';
                        vn.parity       := '0';
                    end if;
                elsif (vp.bit_count = 0 and vp.state = ST_EVEN0) then
                    if vp.parity = '0' then
                        vn.error_parity := '1';
                    else
                        vn.parity := '0';
                    end if;
                elsif (vp.state = ST_ODD1 or vp.state = ST_EVEN1) then
                    vn.parity := not vp.parity;
                end if;
            else
                vn.error_parity := '0';
            end if;

            ----------------------------------------------------------------------
            -- ECSS-E-ST-50-12C 8.5.3.7.2 Disconnect error.
            -- Disconnect error is an error condition asserted
            -- when the length of time since the last transition on
            -- the D or S lines was longer than 850 ns nominal.
            ----------------------------------------------------------------------
            if (enableReceive = '1' and vp.error_esc = '0' and vp.error_parity = '0') then
                if (vp.state = ST_ODD_WAIT or vp.state = ST_EVEN_WAIT) then
                    if (vp.link_timeout_counter < gDisconnectCountValue) then
                        vn.link_timeout_counter := vp.link_timeout_counter + 1;
                    else
                        vn.error_disconnect := '1';
                    end if;
                elsif (vp.state = ST_IDLE) then
                    vn.link_timeout_counter := RES_registers.link_timeout_counter;
                elsif (vp.state = ST_ODD1 or vp.state = ST_EVEN1 or vp.state = ST_ODD0 or vp.state = ST_EVEN0) then
                    vn.link_timeout_counter := RES_registers.link_timeout_counter;
                end if;
            else
                vn.error_disconnect     := RES_registers.error_disconnect;
                vn.link_timeout_counter := RES_registers.link_timeout_counter;
            end if;

            ----------------------------------------------------------------------
            -- ECSS-E-ST-50-12C 4.4 Character level
            -- ECSS-E-ST-50-12C 7.2 Data characters
            -- Discriminate the data character or the  the control character by the Data
            -- Control Flag.
            ----------------------------------------------------------------------
            if (enableReceive = '1') then
                if (vp.state = ST_IDLE) then
                    vn.flag_command := RES_registers.flag_command;
                    vn.flag_data    := RES_registers.flag_data;
                elsif (vp.bit_count = 0 and vp.state = ST_EVEN0) then
                    vn.flag_command := '0';
                    vn.flag_data    := '1';
                elsif (vp.bit_count = 0 and vp.state = ST_EVEN1) then
                    vn.flag_command := '1';
                    vn.flag_data    := '0';
                end if;
            else
                vn.flag_command := RES_registers.flag_command;
                vn.flag_data    := RES_registers.flag_data;
            end if;

            ----------------------------------------------------------------------
            -- Increment bit of character corresponding by state transition of
            -- spaceWireState.
            ----------------------------------------------------------------------
            if (enableReceive = '1' and vp.error_esc = '0' and vp.error_disconnect = '0') then
                if (vp.state = ST_IDLE or vp.state = ST_OFF) then
                    vn.bit_count := (others => '0');
                elsif (vp.state = ST_EVEN1 or vp.state = ST_EVEN0) then
                    if (vp.bit_count = 1 and vp.flag_command = '1') then
                        vn.bit_count := (others => '0');
                    elsif (vp.bit_count = 4 and vp.flag_command = '0') then
                        vn.bit_count := (others => '0');
                    else
                        vn.bit_count := vp.bit_count + 1;
                    end if;
                end if;
            else
                vn.bit_count := RES_registers.bit_count;
            end if;

            ----------------------------------------------------------------------
            -- ECSS-E-ST-50-12C 7.3 Control characters and control codes.
            -- Discriminate  Data character, Control code and Time corde, and write to
            -- Receive buffer
            ----------------------------------------------------------------------
            if (enableReceive = '1') then
                if (vp.bit_count = 0 and (vp.state = ST_ODD0 or vp.state = ST_ODD1)) then
                    if (vp.flag_data = '1') then
                        if (vp.flag_esc = '1') then
                            --Time Code Receive.
                            vn.timecode := vp.data_reg;
                        else
                            --Data Receive.
                            vn.rx_data  := '0' & vp.data_reg;
                            vn.rx_write := '1';
                        end if;
                    elsif (vp.flag_command = '1') then
                        if (vp.data_reg(7 downto 6) = "10") then --EOP
                            vn.rx_data := '1' & x"00";
                        elsif (vp.data_reg(7 downto 6) = "01") then --EEP
                            vn.rx_data := '1' & x"01";
                        end if;

                        if ((vp.flag_esc /= '1') and (vp.data_reg(7 downto 6) = "10" or vp.data_reg(7 downto 6) = "01")) then
                            --EOP EEP Receive.
                            vn.rx_write := '1';
                        end if;
                    end if;
                else
                    vn.rx_write := '0';
                end if;
            end if;

            ----------------------------------------------------------------------
            -- ECSS-E-ST-50-12C 7.3 Control characters and control codes.
            -- ECSS-E-ST-50-12C 8.5.3.7.4 Escape error.
            -- Receive DataCharacter, ControlCode and TimeCode.
            ----------------------------------------------------------------------
            if (enableReceive = '1' and vp.error_disconnect = '0' and vp.error_parity = '0') then
                if (vp.bit_count = 0 and (vp.state = ST_ODD0 or vp.state = ST_ODD1)) then
                    if (vp.flag_command = '1') then
                        case vp.data_reg(7 downto 6) is
                            ----------------------------------------------------------------------
                            -- ECSS-E-ST-50-12C 8.5.3.2 gotNULL.
                            -- ECSS-E-ST-50-12C 8.5.3.3 gotFCT.
                            ----------------------------------------------------------------------
                            when "00" => -- FCT Receive or Null Receive.
                                if (vp.flag_esc = '1') then
                                    vn.rx_null  := '1';
                                    vn.flag_esc := '0';
                                else
                                    vn.rx_fct := '1';
                                end if;

                            when "11" => -- ESC Receive.
                                if (vp.flag_esc = '1') then
                                    vn.error_esc := '1';
                                else
                                    vn.flag_esc := '1';
                                end if;

                            when "10" => -- EOP Receive.
                                if (vp.flag_esc = '1') then
                                    vn.error_esc := '1';
                                else
                                    vn.rx_eop := '1';
                                end if;

                            when "01" => -- EEP Receive.
                                if (vp.flag_esc = '1') then
                                    vn.error_esc := '1';
                                else
                                    vn.rx_eep := '1';
                                end if;
                            when others => null;
                        end case;

                    ----------------------------------------------------------------------
                    -- ECSS-E-ST-50-12C 8.5.3.5 gotTime-Code.
                    -- ECSS-E-ST-50-12C 8.5.3.4 gotN-Char.
                    ----------------------------------------------------------------------
                    elsif (vp.flag_data = '1') then
                        if (vp.flag_esc = '1') then -- TimeCode_Receive.
                            vn.timecode_valid := '1';
                            vn.flag_esc       := '0';
                        else            --N-Char_Receive.
                            vn.rx_valid := '1';
                        end if;
                    end if;

                ----------------------------------------------------------------------
                -- Clear the previous Receive flag before receiving data.
                ----------------------------------------------------------------------
                elsif (vp.bit_count = 1 and (vp.state = ST_ODD0 or vp.state = ST_ODD1)) then
                    vn.rx_valid       := '0';
                    vn.timecode_valid := '0';
                    vn.rx_null        := '0';
                    vn.rx_fct         := '0';
                    vn.rx_eop         := '0';
                    vn.rx_eep         := '0';
                elsif vp.state = ST_IDLE then
                    vn.rx_valid       := '0';
                    vn.timecode_valid := '0';
                    vn.rx_null        := '0';
                    vn.rx_fct         := '0';
                    vn.rx_eop         := '0';
                    vn.rx_eep         := '0';
                    vn.error_esc      := '0';
                    vn.flag_esc       := '0';
                end if;
            else
                vn.rx_valid       := '0';
                vn.timecode_valid := '0';
                vn.rx_null        := '0';
                vn.rx_fct         := '0';
                vn.rx_eop         := '0';
                vn.rx_eep         := '0';
                vn.error_esc      := '0';
                vn.flag_esc       := '0';
            end if;

            if (vp.error_disconnect = '1') then
                vn.state := RES_registers.state;
            end if;

            if (r(i).state = ST_ODD1 or r(i).state = ST_EVEN1 or r(i).state = ST_ODD0 or r(i).state = ST_EVEN0) then
                v_index := i;
            end if;

            if (i = 0) then
                rin(1) <= vn;
            else
                rin(0) <= vn;
            end if;
        end loop;
        rin_index <= v_index;
    end process comb;

    seq : process(receiveClock, spaceWireReset) is
    begin
        if (spaceWireReset = '1') then
            r <= (others => RES_registers);
            r_index <= 0;
        elsif rising_edge(receiveClock) then
            r <= rin;
            r_index <= rin_index;
        end if;
    end process seq;

    rs <= r(r_index);
    receiveDataOut          <= rs.rx_data;
    receiveTimeCodeOut      <= rs.timecode;
    receiveTimeCodeValidOut <= rs.timecode_valid;
    receiveNCharacterOut    <= (rs.rx_eop or rs.rx_eep or rs.rx_valid);
    receiveFCTOut           <= rs.rx_fct;
    receiveNullOut          <= rs.rx_null;
    receiveOffOut           <= '1' when rs.state = ST_OFF else '0';
    receiverErrorOut        <= (rs.error_disconnect or rs.error_parity or rs.error_esc);
    receiveFIFOWriteEnable  <= rs.rx_write;
    receiveDataValidOut     <= rs.rx_valid;
    receiveEOPOut           <= rs.rx_eop;
    receiveEEPOut           <= rs.rx_eep;
    parityErrorOut          <= rs.error_parity;
    escapeErrorOut          <= rs.error_esc;
    disconnectErrorOut      <= rs.error_disconnect;

end RTL;

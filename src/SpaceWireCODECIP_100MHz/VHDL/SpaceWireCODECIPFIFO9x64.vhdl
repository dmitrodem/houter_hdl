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

use work.ftlib.all;

entity SpaceWireCODECIPFIFO9x64 is
    generic(
        tech : integer
    );
    port(
        reset          : in  std_logic;
        writeClock     : in  std_logic;
        readClock      : in  std_logic;
        writeDataIn    : in  std_logic_vector(8 downto 0);
        writeEnable    : in  std_logic;
        readEnable     : in  std_logic;
        readDataOut    : out std_logic_vector(8 downto 0);
        empty          : out std_logic;
        full           : out std_logic;
        readDataCount  : out std_logic_vector(5 downto 0);
        writeDataCount : out std_logic_vector(5 downto 0);
        testen         : in  std_logic
    );

end SpaceWireCODECIPFIFO9x64;

architecture RTL of SpaceWireCODECIPFIFO9x64 is

    type turnMemory is array (0 to 63) of std_logic_vector(8 downto 0);
    signal dpram : turnMemory;

    type turnTable is array (0 to 63) of unsigned(5 downto 0);

    constant binaryToGray : turnTable := (
        "000000", "000001", "000011", "000010",
        "000110", "000111", "000101", "000100",
        "001100", "001101", "001111", "001110",
        "001010", "001011", "001001", "001000",
        "011000", "011001", "011011", "011010",
        "011110", "011111", "011101", "011100",
        "010100", "010101", "010111", "010110",
        "010010", "010011", "010001", "010000",
        "110000", "110001", "110011", "110010",
        "110110", "110111", "110101", "110100",
        "111100", "111101", "111111", "111110",
        "111010", "111011", "111001", "111000",
        "101000", "101001", "101011", "101010",
        "101110", "101111", "101101", "101100",
        "100100", "100101", "100111", "100110",
        "100010", "100011", "100001", "100000");

    constant grayToBinary : turnTable := (
        "000000", "000001", "000011", "000010",
        "000111", "000110", "000100", "000101",
        "001111", "001110", "001100", "001101",
        "001000", "001001", "001011", "001010",
        "011111", "011110", "011100", "011101",
        "011000", "011001", "011011", "011010",
        "010000", "010001", "010011", "010010",
        "010111", "010110", "010100", "010101",
        "111111", "111110", "111100", "111101",
        "111000", "111001", "111011", "111010",
        "110000", "110001", "110011", "110010",
        "110111", "110110", "110100", "110101",
        "100000", "100001", "100011", "100010",
        "100111", "100110", "100100", "100101",
        "101111", "101110", "101100", "101101",
        "101000", "101001", "101011", "101010");

    signal iWriteReset, xWriteReset : std_logic;
    signal iReadReset, xReadReset   : std_logic;
    signal iWriteResetTime          : std_logic_vector(1 downto 0);
    signal iReadResetTime           : std_logic_vector(1 downto 0);
    signal iWritePointer            : unsigned(5 downto 0);
    signal iGrayWritePointer        : unsigned(5 downto 0);
    signal iGrayWritePointer1       : unsigned(5 downto 0);
    signal iGrayWritePointer2       : unsigned(5 downto 0);
    signal iGrayWritePointer3       : unsigned(5 downto 0);
    signal iWritePointer4           : unsigned(5 downto 0);
    signal iReadPointer             : unsigned(5 downto 0);
    signal iGrayReadPointer         : unsigned(5 downto 0);
    signal iGrayReadPointer1        : unsigned(5 downto 0);
    signal iGrayReadPointer2        : unsigned(5 downto 0);
    signal iReadPointer3            : unsigned(5 downto 0);
    signal iWriteDataCount          : unsigned(5 downto 0);
    signal iFull                    : std_logic;
    signal iReadDataOut             : std_logic_vector(8 downto 0);
    signal iReadDataCount           : unsigned(5 downto 0);
    signal iEmpty                   : std_logic;

    component hcmos8d_dp_0128x08m16
        port(
            QA   : out std_logic_vector(7 downto 0);
            CLKA : in  std_logic;
            CENA : in  std_logic;
            WENA : in  std_logic;
            AA   : in  std_logic_vector(6 downto 0);
            DA   : in  std_logic_vector(7 downto 0);
            QB   : out std_logic_vector(7 downto 0);
            CLKB : in  std_logic;
            CENB : in  std_logic;
            WENB : in  std_logic;
            AB   : in  std_logic_vector(6 downto 0);
            DB   : in  std_logic_vector(7 downto 0)
        );
    end component hcmos8d_dp_0128x08m16;
    signal qa_unused : std_logic_vector(7 downto 1);
begin

    writeDataCount <= std_logic_vector(iWriteDataCount);
    full           <= iFull;
    empty          <= iEmpty;
    readDataCount  <= std_logic_vector(iReadDataCount);
    readDataOut    <= iReadDataOut;

    ----------------------------------------------------------------------
    -- synchronized Reset.
    ----------------------------------------------------------------------
    process(reset, writeClock)
    begin
        if (reset = '1') then
            iWriteResetTime <= (others => '1');
            xWriteReset     <= '1';
        elsif (writeClock'event and writeClock = '1') then
            iWriteResetTime <= iWriteResetTime(0) & reset;
            xWriteReset     <= iWriteResetTime(1);
        end if;
    end process;

    iWriteReset <= reset when testen = '1' else xWriteReset;
    ----------------------------------------------------------------------
    -- Write pointer of the buffer.
    ----------------------------------------------------------------------
    process(iWriteReset, writeClock)
    begin
        if (iWriteReset = '1') then
            iWritePointer <= (others => '0');
        elsif (writeClock'event and writeClock = '1') then
            if (writeEnable = '1') then
                iWritePointer <= iWritePointer + '1';
            end if;
        end if;
    end process;

    iWriteDataCount <= iWritePointer - iReadPointer3;

    ----------------------------------------------------------------------
    -- Change to Gray code.
    ----------------------------------------------------------------------
    process(iWriteReset, writeClock)
    begin
        if (iWriteReset = '1') then
            iGrayWritePointer <= (others => '0');
        elsif (writeClock'event and writeClock = '1') then
            iGrayWritePointer <= binaryToGray(to_integer(iWritePointer));
        end if;
    end process;

    iFull <= '1' when ((iWritePointer - iReadPointer3) > "111000") or iWriteReset = '1' else '0';

    ----------------------------------------------------------------------
    -- Convert gray code Readpointer to binary Readpointer to calculate writeDataCount and full.
    ----------------------------------------------------------------------
    process(iWriteReset, writeClock)
    begin
        if (iWriteReset = '1') then
            iGrayReadPointer1 <= (others => '0');
            iGrayReadPointer2 <= (others => '0');
            iReadPointer3     <= (others => '0');
        elsif (writeClock'event and writeClock = '1') then
            iGrayReadPointer1 <= iGrayReadPointer;
            iGrayReadPointer2 <= iGrayReadPointer1;
            iReadPointer3     <= grayToBinary(to_integer(iGrayReadPointer2));
        end if;
    end process;

    ----------------------------------------------------------------------
    -- Convert gray code Writepointer to binary Writepointer to calculate readDataCount and empty.
    ----------------------------------------------------------------------
    process(iReadReset, readClock)
    begin
        if (iReadReset = '1') then
            iGrayWritePointer1 <= (others => '0');
            iGrayWritePointer2 <= (others => '0');
            iGrayWritePointer3 <= (others => '0');
            iWritePointer4     <= (others => '0');
        elsif (readClock'event and readClock = '1') then
            iGrayWritePointer1 <= iGrayWritePointer;
            iGrayWritePointer2 <= iGrayWritePointer1;
            iGrayWritePointer3 <= iGrayWritePointer2;
            iWritePointer4     <= grayToBinary(to_integer(iGrayWritePointer3));
        end if;
    end process;

    iReadDataCount <= iWritePointer4 - iReadPointer;

    ----------------------------------------------------------------------
    -- Read pointer of the buffer.
    ----------------------------------------------------------------------
    process(iReadReset, readClock)
    begin
        if (iReadReset = '1') then
            iReadPointer <= (others => '0');
        elsif (readClock'event and readClock = '1') then
            if (iEmpty = '0') then
                if readEnable = '1' then
                    iReadPointer <= iReadPointer + '1';
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------------
    -- Change to Gray code.
    ----------------------------------------------------------------------
    process(iReadReset, readClock)
    begin
        if (iReadReset = '1') then
            iGrayReadPointer <= (others => '0');
        elsif (readClock'event and readClock = '1') then
            iGrayReadPointer <= binaryToGray(to_integer(iReadPointer));
        end if;
    end process;

    ----------------------------------------------------------------------
    -- Generate the EMPTY signal.
    ----------------------------------------------------------------------
    iEmpty <= '1' when iWritePointer4 = iReadPointer or iReadReset = '1' else '0';

    ----------------------------------------------------------------------
    -- synchronized Reset.
    ----------------------------------------------------------------------
    process(reset, readClock)
    begin
        if (reset = '1') then
            iReadResetTime <= (others => '1');
            xReadReset     <= '1';
        elsif (readClock'event and readClock = '1') then
            iReadResetTime <= iReadResetTime(0) & reset;
            xReadReset     <= iReadResetTime(1);
        end if;
    end process;

    iReadReset <= reset when testen = '1' else xReadReset;

    use_simulation_ram : if tech = 0 generate
        ----------------------------------------------------------------------
        -- Writing to buffer.
        ----------------------------------------------------------------------
        process(writeClock)
        begin
            if (writeClock'event and writeClock = '1') then
                if (writeEnable = '1') then
                    dpram(to_integer(iWritePointer)) <= writeDataIn;
                end if;
            end if;
        end process;
        ----------------------------------------------------------------------
        -- Read from buffer.
        ----------------------------------------------------------------------
        process(readClock)
        begin
            if (readClock'event and readClock = '1') then
                if ((not iEmpty) and readEnable) = '1' then
                    iReadDataOut <= dpram(to_integer(iReadPointer));
                end if;
            end if;
        end process;
    end generate use_simulation_ram;

    use_hcmos8d_ram : if tech /= 0 generate
        blk_hcmos8d_ram : block
            signal hcmos8d_data_in      : std_logic_vector(31 downto 0);
            signal hcmos8d_data_out     : std_logic_vector(31 downto 0);
            signal hcmos8d_write_enable : std_logic;
            signal hcmos8d_read_enable  : std_logic;

        begin
            loop_hcmos8d_ram : for i in 0 to 3 generate
                ram : hcmos8d_dp_0128x08m16
                    port map(
                        QA   => hcmos8d_data_out(31 - 8 * i downto 24 - 8 * i),
                        CLKA => readClock,
                        CENA => hcmos8d_read_enable,
                        WENA => '1',
                        AA   => "0" & std_logic_vector(iReadPointer),
                        DA   => (others => '0'),
                        QB   => open,
                        CLKB => writeClock,
                        CENB => hcmos8d_write_enable,
                        WENB => '0',
                        AB   => "0" & std_logic_vector(iWritePointer),
                        DB   => hcmos8d_data_in(31 - 8 * i downto 24 - 8 * i)
                    );
            end generate loop_hcmos8d_ram;
            iReadDataOut         <= writeDataIn when testen = '1' else
                                    mvote(
                                        hcmos8d_data_out(26 downto 18),
                                        hcmos8d_data_out(17 downto 9),
                                        hcmos8d_data_out(8 downto 0));
            hcmos8d_data_in      <= "00000" & writeDataIn & writeDataIn & writeDataIn;
            hcmos8d_read_enable  <= '1' when testen = '1' else (not readEnable);
            hcmos8d_write_enable <= '1' when testen = '1' else (not writeEnable);
        end block blk_hcmos8d_ram;
    end generate use_hcmos8d_ram;

end RTL;

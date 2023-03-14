-- [[[cog
-- n = int(nports) + 1
-- ]]]
-- [[[end]]]

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.spwpkg.all;
use work.rmap_crc.all;
use work.rmap_pkg.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

use work.spw_actor_pkg.all;
use work.test_mem_actor_pkg.all;

library osvvm;
use osvvm.RandomPkg.all;

entity tb_router is
  generic (
    runner_cfg : string);
end entity tb_router;

architecture behav of tb_router is

  constant sysfreq   : real := 100.0e6;

  constant RT_SYSCLK_FREQ : real := 50.0e6;
  constant RT_TXCLK_FREQ  : real := 100.0e6;
  constant RT_RXCLK_FREQ  : real := 200.0e6;

  constant T : time := (1.0/sysfreq) * (1.0e3 ms);

  constant Tsys : time := (1.0e3 ms) / RT_SYSCLK_FREQ;
  constant Ttx  : time := (1.0e3 ms) / RT_TXCLK_FREQ;
  constant Trx  : time := (1.0e3 ms) / RT_RXCLK_FREQ;

  -- [[[cog
  -- print(f"constant N_PORTS : integer := {n-1};")
  -- ]]]
  constant N_PORTS : integer := 6;
  -- [[[end]]]

  signal clk          : std_logic;
  signal rst          : std_logic;

  signal clk_sys, clk_tx, clk_rx : std_logic;
  -- [[[cog
  -- for i in range(0, n-1):
  --   print(f"signal spw_di_{i}     : std_logic := '0';")
  --   print(f"signal spw_si_{i}     : std_logic := '0';")
  --   print(f"signal spw_do_{i}     : std_logic := '0';")
  --   print(f"signal spw_so_{i}     : std_logic := '0';")
  -- ]]]
  signal spw_di_0     : std_logic := '0';
  signal spw_si_0     : std_logic := '0';
  signal spw_do_0     : std_logic := '0';
  signal spw_so_0     : std_logic := '0';
  signal spw_di_1     : std_logic := '0';
  signal spw_si_1     : std_logic := '0';
  signal spw_do_1     : std_logic := '0';
  signal spw_so_1     : std_logic := '0';
  signal spw_di_2     : std_logic := '0';
  signal spw_si_2     : std_logic := '0';
  signal spw_do_2     : std_logic := '0';
  signal spw_so_2     : std_logic := '0';
  signal spw_di_3     : std_logic := '0';
  signal spw_si_3     : std_logic := '0';
  signal spw_do_3     : std_logic := '0';
  signal spw_so_3     : std_logic := '0';
  signal spw_di_4     : std_logic := '0';
  signal spw_si_4     : std_logic := '0';
  signal spw_do_4     : std_logic := '0';
  signal spw_so_4     : std_logic := '0';
  signal spw_di_5     : std_logic := '0';
  signal spw_si_5     : std_logic := '0';
  signal spw_do_5     : std_logic := '0';
  signal spw_so_5     : std_logic := '0';
  -- [[[end]]]

  signal testen            : std_logic;
  signal test_mem_address  : std_logic_vector(31 downto 0);
  signal test_mem_data_in  : std_logic_vector(7 downto 0);
  signal test_mem_cen      : std_logic;
  signal test_mem_wen      : std_logic;
  signal test_mem_data_out : std_logic_vector(7 downto 0);

begin  -- architecture behav
  -- [[[cog
  -- tmpl = """
  -- link{i}: entity work.spw_actor
  -- generic map (
  --   name      => "e{i}",
  --   sysfreq   => sysfreq,
  --   txclkfreq => sysfreq)
  -- port map (
  --   clk    => clk,
  --   rst    => rst,
  --   spw_di => spw_di_{i},
  --   spw_si => spw_si_{i},
  --   spw_do => spw_do_{i},
  --   spw_so => spw_so_{i});
  -- """.strip()
  -- for i in range(0, n-1):
  --   print(tmpl.format(i = i))
  -- ]]]
  link0: entity work.spw_actor
  generic map (
    name      => "e0",
    sysfreq   => sysfreq,
    txclkfreq => sysfreq)
  port map (
    clk    => clk,
    rst    => rst,
    spw_di => spw_di_0,
    spw_si => spw_si_0,
    spw_do => spw_do_0,
    spw_so => spw_so_0);
  link1: entity work.spw_actor
  generic map (
    name      => "e1",
    sysfreq   => sysfreq,
    txclkfreq => sysfreq)
  port map (
    clk    => clk,
    rst    => rst,
    spw_di => spw_di_1,
    spw_si => spw_si_1,
    spw_do => spw_do_1,
    spw_so => spw_so_1);
  link2: entity work.spw_actor
  generic map (
    name      => "e2",
    sysfreq   => sysfreq,
    txclkfreq => sysfreq)
  port map (
    clk    => clk,
    rst    => rst,
    spw_di => spw_di_2,
    spw_si => spw_si_2,
    spw_do => spw_do_2,
    spw_so => spw_so_2);
  link3: entity work.spw_actor
  generic map (
    name      => "e3",
    sysfreq   => sysfreq,
    txclkfreq => sysfreq)
  port map (
    clk    => clk,
    rst    => rst,
    spw_di => spw_di_3,
    spw_si => spw_si_3,
    spw_do => spw_do_3,
    spw_so => spw_so_3);
  link4: entity work.spw_actor
  generic map (
    name      => "e4",
    sysfreq   => sysfreq,
    txclkfreq => sysfreq)
  port map (
    clk    => clk,
    rst    => rst,
    spw_di => spw_di_4,
    spw_si => spw_si_4,
    spw_do => spw_do_4,
    spw_so => spw_so_4);
  link5: entity work.spw_actor
  generic map (
    name      => "e5",
    sysfreq   => sysfreq,
    txclkfreq => sysfreq)
  port map (
    clk    => clk,
    rst    => rst,
    spw_di => spw_di_5,
    spw_si => spw_si_5,
    spw_do => spw_do_5,
    spw_so => spw_so_5);
  -- [[[end]]]

  testmem0: entity work.test_mem_actor
      generic map(
          name => "mem0"
      )
      port map(
          clk               => clk_sys,
          test_mem_address  => test_mem_address,
          test_mem_data_in  => test_mem_data_in,
          test_mem_cen      => test_mem_cen,
          test_mem_wen      => test_mem_wen,
          test_mem_data_out => test_mem_data_out
      );


  router0 : entity work.SpaceWireRouterIP
    generic map (
      clkfreq => RT_SYSCLK_FREQ,
      txclkfreq => RT_TXCLK_FREQ,
      tech => 1)
    port map (
      clock                       => clk_sys,
      transmitClock               => clk_tx,
      receiveClock                => clk_rx,
      reset                       => rst,
      -- [[[cog
      -- for i in range(1, n):
      --   print(f"spaceWireDataIn{i}            => spw_do_{i-1},")
      --   print(f"spaceWireStrobeIn{i}          => spw_so_{i-1},")
      --   print(f"spaceWireDataOut{i}           => spw_di_{i-1},")
      --   print(f"spaceWireStrobeOut{i}         => spw_si_{i-1},")
      -- ]]]
      spaceWireDataIn1            => spw_do_0,
      spaceWireStrobeIn1          => spw_so_0,
      spaceWireDataOut1           => spw_di_0,
      spaceWireStrobeOut1         => spw_si_0,
      spaceWireDataIn2            => spw_do_1,
      spaceWireStrobeIn2          => spw_so_1,
      spaceWireDataOut2           => spw_di_1,
      spaceWireStrobeOut2         => spw_si_1,
      spaceWireDataIn3            => spw_do_2,
      spaceWireStrobeIn3          => spw_so_2,
      spaceWireDataOut3           => spw_di_2,
      spaceWireStrobeOut3         => spw_si_2,
      spaceWireDataIn4            => spw_do_3,
      spaceWireStrobeIn4          => spw_so_3,
      spaceWireDataOut4           => spw_di_3,
      spaceWireStrobeOut4         => spw_si_3,
      spaceWireDataIn5            => spw_do_4,
      spaceWireStrobeIn5          => spw_so_4,
      spaceWireDataOut5           => spw_di_4,
      spaceWireStrobeOut5         => spw_si_4,
      spaceWireDataIn6            => spw_do_5,
      spaceWireStrobeIn6          => spw_so_5,
      spaceWireDataOut6           => spw_di_5,
      spaceWireStrobeOut6         => spw_si_5,
      -- [[[end]]]
      -- [[[cog
      -- for i in range(1, n):
      --   print(f"statisticalInformationPort{i} => open,")
      -- ]]]
      statisticalInformationPort1 => open,
      statisticalInformationPort2 => open,
      statisticalInformationPort3 => open,
      statisticalInformationPort4 => open,
      statisticalInformationPort5 => open,
      statisticalInformationPort6 => open,
      -- [[[end]]]
      -- [[[cog
      -- for i in range(1, n):
      --   print(f"oneShotStatusPort{i}          => open,")
      -- ]]]
      oneShotStatusPort1          => open,
      oneShotStatusPort2          => open,
      oneShotStatusPort3          => open,
      oneShotStatusPort4          => open,
      oneShotStatusPort5          => open,
      oneShotStatusPort6          => open,
      -- [[[end]]]
      busMasterUserAddressIn      => (others => '0'),
      busMasterUserDataOut        => open,
      busMasterUserDataIn         => (others => '0'),
      busMasterUserWriteEnableIn  => '0',
      busMasterUserByteEnableIn   => (others => '0'),
      busMasterUserStrobeIn       => '0',
      busMasterUserRequestIn      => '0',
      busMasterUserAcknowledgeOut => open,
      testen => testen,
      test_mem_address => test_mem_address,
      test_mem_data_in => test_mem_data_in,
      test_mem_cen => test_mem_cen,
      test_mem_wen => test_mem_wen,
      test_mem_data_out => test_mem_data_out
  );

  generate_clock : process is
  begin  -- process generate_clock
    clk <= '0';
    wait for 10*T;
    while true loop
      clk <= '1';
      wait for 0.5*T;
      clk <= '0';
      wait for 0.5*T;
    end loop;
    wait;
  end process generate_clock;

  -- [[[cog
  -- tmpl = """
  -- generate_{name}_clock: process is
  -- begin
  --   clk_{name} <= '0';
  --   wait for 10*T{name};
  --   while true loop
  --     clk_{name} <= '1';
  --     wait for 0.5*T{name};
  --     clk_{name} <= '0';
  --     wait for 0.5*T{name};
  --   end loop;
  --   wait;
  -- end process;
  -- """.strip()
  -- for name in ["sys", "tx", "rx"]:
  --   print(tmpl.format(name = name))
  -- ]]]
  generate_sys_clock: process is
  begin
    clk_sys <= '0';
    wait for 10*Tsys;
    while true loop
      clk_sys <= '1';
      wait for 0.5*Tsys;
      clk_sys <= '0';
      wait for 0.5*Tsys;
    end loop;
    wait;
  end process;
  generate_tx_clock: process is
  begin
    clk_tx <= '0';
    wait for 10*Ttx;
    while true loop
      clk_tx <= '1';
      wait for 0.5*Ttx;
      clk_tx <= '0';
      wait for 0.5*Ttx;
    end loop;
    wait;
  end process;
  generate_rx_clock: process is
  begin
    clk_rx <= '0';
    wait for 10*Trx;
    while true loop
      clk_rx <= '1';
      wait for 0.5*Trx;
      clk_rx <= '0';
      wait for 0.5*Trx;
    end loop;
    wait;
  end process;
  -- [[[end]]]

  sim : process is

    variable rnd     : RandomPType;
    variable d       : std_logic_vector (31 downto 0);
    variable a       : std_logic_vector (31 downto 0);
    variable r       : std_logic_vector (31 downto 0);
    variable d8      : std_logic_vector (7 downto 0);

    type rmap_hdr_t is protected
      procedure init;
      procedure append (d    : std_logic_vector (7 downto 0));
      procedure finalize;
      impure function length return integer;
      impure function get (i : integer) return std_logic_vector;
    end protected;

    type rmap_hdr_t is protected body
      variable r : integer_array_t;
      variable crc : crc_t;
      procedure init is
      begin
        crc.init;
        r := new_1d(0, 8, false);
      end;
      procedure append (d : std_logic_vector (7 downto 0)) is
      begin
        crc.update(d);
        append(r, to_integer(unsigned(d)));
      end;
      procedure finalize is
      begin
        crc.finalize;
        append(r, crc.get);
      end;
      impure function get(i : integer) return std_logic_vector is
      begin
        return std_logic_vector(to_unsigned(get(r, i), 8));
      end;
      impure function length return integer is
      begin
        return r.length;
      end;
  end protected body;

  variable rmap_hdr    : rmap_hdr_t;
  variable msg, msgr   : msg_t;
  constant self        : actor_t         := new_actor("checker");
  variable linkstatus  : std_logic_vector (2 downto 0);
  variable test_packet : integer_array_t := null_integer_array;

  procedure enable_link (link : actor_t) is
  begin
    msg := new_msg(spw_type_linkctl);
    push(msg, std_logic_vector'("110"));
    send(net, link, msg);
    delete(msg);

    rst <= '1';
    wait for 20*T;
    rst <= '0';

    msg := new_msg(spw_type_pollrunning);
    send(net, link, msg);
    receive_reply(net, msg, msgr);
    check(message_type(msgr) = spw_type_pollrunning_reply);
  end procedure;

  procedure rmap_read_32 (
    link          :     actor_t;
    subscriber    :     actor_t;
    address       :     std_logic_vector (31 downto 0);
    variable data : out std_logic_vector (31 downto 0)) is
    variable hdr    : rmap_hdr_t;
    variable m0, m1 : msg_t;
    variable i      : integer;
    variable chk    : crc_t;
    variable v8     : std_logic_vector (7 downto 0);
    variable v32    : std_logic_vector (31 downto 0);
  begin
    hdr.init;
    hdr.append(std_logic_vector(to_unsigned(RMAP_DEFAULT_LOGICAL_ADDRESS, 8)));  -- target logical address
    hdr.append(std_logic_vector(to_unsigned(RMAP_PROTOCOL_ID, 8)));  -- protocol ID (RMAP)
    hdr.append(
      "01" &                            -- packet type (COMMAND)
      "0" &                             -- write/read (READ)
      "0" &                             -- verify (NO VERIFY)
      "1" &                             -- reply (DO REPLY)
      "1" &  -- single/incrementing address (INCREMENT)
      "00"                              -- reply address length (0)
      );
    hdr.append(x"02");                  -- RMAP key
    hdr.append(std_logic_vector(to_unsigned(RMAP_DEFAULT_LOGICAL_ADDRESS, 8)));  -- Initiator logical address (default)
    hdr.append(x"00");                  -- TX ID MSB
    hdr.append(x"05");                  -- TX ID LSB
    hdr.append(x"00");                  -- Extended address
    hdr.append(address(31 downto 24));  -- Address MSB
    hdr.append(address(23 downto 16));
    hdr.append(address(15 downto 8));
    hdr.append(address(7 downto 0));    -- Address LSB
    hdr.append(x"00");                  -- Data length MSB
    hdr.append(x"00");
    hdr.append(x"04");                  -- Data length LSB
    hdr.finalize;

    m0 := new_msg(spw_type_txdata);
    push(m0, std_logic_vector'(x"00"));  -- Cfg link physical address
    for i in 0 to hdr.length - 1 loop
      push(m0, hdr.get(i));
    end loop;  -- i
    send(net, link, m0);
    delete(m0);

    receive(net, subscriber, m1);

    i := 0;
    chk.init;
    while not is_empty(m1) loop
      v8 := pop(m1);
      case i is
        when 0 => check(unsigned(v8) = RMAP_DEFAULT_LOGICAL_ADDRESS, "Initiator Logical Address");
        when 1 => check(unsigned(v8) = RMAP_PROTOCOL_ID, "Protocol Identifier");
        when 2 => check_equal(v8, std_logic_vector'("00" & "0011" & "00"), "Instruction");
        when 3 => check_equal(v8, std_logic_vector'(x"00"), "Status");
        when 4 => check(unsigned(v8) = RMAP_DEFAULT_LOGICAL_ADDRESS, "Target Logical Address");
        when 5 => check_equal(v8, std_logic_vector'(x"00"), "TX ID MSB");
        when 6 => check_equal(v8, std_logic_vector'(x"05"), "TX ID LSB");
        when 7 => check_equal(v8, std_logic_vector'(x"00"), "Reserved");
        when 8 => v32 := x"00000000";
                  v32 (23 downto 16) := v8;
        when 9  => v32 (15 downto 8) := v8;
        when 10 => v32 (7 downto 0)  := v8;
                   check(unsigned(v32) = 4, "Data Length");
        when 11 => chk.finalize;
                   check(v8 = chk.get, "Header CRC");
        when 12 => chk.init;
                   v32               := x"00000000";
                   v32(31 downto 24) := v8;
        when 13 => v32(23 downto 16) := v8;
        when 14 => v32(15 downto 8)  := v8;
        when 15 => v32(7 downto 0)   := v8;
        when 16 => chk.finalize;
                   check(v8 = chk.get, "Data CRC");
                   data := v32;
        when others => assert false report "Excessive data in RMAP reply" severity failure;
      end case;
      chk.update(v8);
      i := i + 1;
    end loop;
  end procedure;

  procedure rmap_write_32 (
    link       : actor_t;
    subscriber : actor_t;
    address    : std_logic_vector (31 downto 0);
    data       : std_logic_vector (31 downto 0)) is
    variable hdr     : rmap_hdr_t;
    variable payload : rmap_hdr_t;
    variable m0, m1  : msg_t;
    variable i       : integer;
    variable chk     : crc_t;
    variable v8      : std_logic_vector (7 downto 0);
  begin
    hdr.init;
    hdr.append(std_logic_vector(to_unsigned(RMAP_DEFAULT_LOGICAL_ADDRESS, 8)));  -- target logical address
    hdr.append(std_logic_vector(to_unsigned(RMAP_PROTOCOL_ID, 8)));  -- protocol ID (RMAP)
    hdr.append(
      "01" &                            -- packet type (COMMAND)
      "1" &                             -- write/read (WRITE)
      "0" &                             -- verify (NO VERIFY)
      "1" &                             -- reply (DO REPLY)
      "1" &  -- single/incrementing address (INCREMENT)
      "00"                              -- reply address length (0)
      );
    hdr.append(x"02");                  -- RMAP key
    hdr.append(std_logic_vector(to_unsigned(RMAP_DEFAULT_LOGICAL_ADDRESS, 8)));  -- Initiator logical address (default)
    hdr.append(x"00");                  -- TX ID MSB
    hdr.append(x"05");                  -- TX ID LSB
    hdr.append(x"00");                  -- Extended address
    hdr.append(address(31 downto 24));  -- Address MSB
    hdr.append(address(23 downto 16));
    hdr.append(address(15 downto 8));
    hdr.append(address(7 downto 0));    -- Address LSB
    hdr.append(x"00");                  -- Data length MSB
    hdr.append(x"00");
    hdr.append(x"04");                  -- Data length LSB
    hdr.finalize;

    payload.init;
    payload.append(data(31 downto 24));
    payload.append(data(23 downto 16));
    payload.append(data(15 downto 8));
    payload.append(data(7 downto 0));
    payload.finalize;

    m0 := new_msg(spw_type_txdata);
    push(m0, std_logic_vector'(x"00"));  -- Cfg link physical address
    for i in 0 to hdr.length - 1 loop
      push(m0, hdr.get(i));
    end loop;  -- i
    for i in 0 to payload.length - 1 loop
      push(m0, payload.get(i));
    end loop;  -- i
    send(net, link, m0);
    delete(m0);

    receive(net, subscriber, m1);

    i := 0;
    chk.init;
    while not is_empty(m1) loop
      v8 := pop(m1);
      case i is
        when 0 => check(unsigned(v8) = RMAP_DEFAULT_LOGICAL_ADDRESS, "Initiator Logical Address");
        when 1 => check(unsigned(v8) = RMAP_PROTOCOL_ID, "Protocol Identifier");
        when 2 => check_equal(v8, std_logic_vector'("00" & "1011" & "00"), "Instruction");
        when 3 => check_equal(v8, std_logic_vector'(x"00"), "Status");
        when 4 => check(unsigned(v8) = RMAP_DEFAULT_LOGICAL_ADDRESS, "Target Logical Address");
        when 5 => check_equal(v8, std_logic_vector'(x"00"), "TX ID MSB");
        when 6 => check_equal(v8, std_logic_vector'(x"05"), "TX ID LSB");
        when 7 => chk.finalize;
                  check(v8 = chk.get, "Header CRC");
        when others => assert false report "Excessive data in RMAP reply" severity failure;
      end case;
      chk.update(v8);
      i := i + 1;
    end loop;
  end procedure;

  procedure rmap_write_32 (
    link       : actor_t;
    subscriber : actor_t;
    address    : std_logic_vector (31 downto 0);
    data       : std_logic_vector (31 downto 0);
    mask       : std_logic_vector (31 downto 0);
    variable reply : out std_logic_vector (31 downto 0)) is
    variable hdr     : rmap_hdr_t;
    variable payload : rmap_hdr_t;
    variable m0, m1  : msg_t;
    variable i       : integer;
    variable chk     : crc_t;
    variable v8      : std_logic_vector (7 downto 0);
    variable v32     : std_logic_vector (31 downto 0);
  begin
    hdr.init;
    hdr.append(std_logic_vector(to_unsigned(RMAP_DEFAULT_LOGICAL_ADDRESS, 8)));  -- target logical address
    hdr.append(std_logic_vector(to_unsigned(RMAP_PROTOCOL_ID, 8)));  -- protocol ID (RMAP)
    hdr.append(
      "01" &                            -- packet type (COMMAND)
      "0" &                             -- write/read (READ)
      "1" &                             -- verify (VERIFY)
      "1" &                             -- reply (DO REPLY)
      "1" &  -- single/incrementing address (INCREMENT)
      "00"                              -- reply address length (0)
      );
    hdr.append(x"02");                  -- RMAP key
    hdr.append(std_logic_vector(to_unsigned(RMAP_DEFAULT_LOGICAL_ADDRESS, 8)));  -- Initiator logical address (default)
    hdr.append(x"00");                  -- TX ID MSB
    hdr.append(x"05");                  -- TX ID LSB
    hdr.append(x"00");                  -- Extended address
    hdr.append(address(31 downto 24));  -- Address MSB
    hdr.append(address(23 downto 16));
    hdr.append(address(15 downto 8));
    hdr.append(address(7 downto 0));    -- Address LSB
    hdr.append(x"00");                  -- Data length MSB
    hdr.append(x"00");
    hdr.append(x"08");                  -- Data length LSB
    hdr.finalize;

    payload.init;
    payload.append(data(31 downto 24));
    payload.append(data(23 downto 16));
    payload.append(data(15 downto 8));
    payload.append(data(7 downto 0));
    payload.append(mask(31 downto 24));
    payload.append(mask(23 downto 16));
    payload.append(mask(15 downto 8));
    payload.append(mask(7 downto 0));
    payload.finalize;

    m0 := new_msg(spw_type_txdata);
    push(m0, std_logic_vector'(x"00"));  -- Cfg link physical address
    for i in 0 to hdr.length - 1 loop
      push(m0, hdr.get(i));
    end loop;  -- i
    for i in 0 to payload.length - 1 loop
      push(m0, payload.get(i));
    end loop;  -- i
    send(net, link, m0);
    delete(m0);

    receive(net, subscriber, m1);

    i := 0;
    chk.init;
    while not is_empty(m1) loop
        v8 := pop(m1);
        case i is
            when 0 => check(unsigned(v8) = RMAP_DEFAULT_LOGICAL_ADDRESS, "Initiator Logical Address");
            when 1 => check(unsigned(v8) = RMAP_PROTOCOL_ID, "Protocol Identifier");
            when 2 => check_equal(v8, std_logic_vector'("00" & "0111" & "00"), "Instruction");
            when 3 => check_equal(v8, std_logic_vector'(x"00"), "Status");
            when 4 => check(unsigned(v8) = RMAP_DEFAULT_LOGICAL_ADDRESS, "Target Logical Address");
            when 5 => check_equal(v8, std_logic_vector'(x"00"), "TX ID MSB");
            when 6 => check_equal(v8, std_logic_vector'(x"05"), "TX ID LSB");
            when 7 => check_equal(v8, std_logic_vector'(x"00"), "Reserved");
            when 8 => v32 := (others => '0');
                v32(23 downto 16) := v8;
            when 9 => v32(15 downto 8) := v8;
            when 10 => v32(7 downto 0) := v8;
                check_equal(v32, std_logic_vector'(x"00000004"), "Data length");
            when 11 => chk.finalize;
                check(v8 = chk.get, "Header CRC");
            when 12 => chk.init;
                reply(31 downto 24) := v8;
            when 13 => reply(23 downto 16) := v8;
            when 14 => reply(15 downto 8) := v8;
            when 15 => reply(7 downto 0) := v8;
            when 16 => chk.finalize;
                check(v8 = chk.get, "Data CRC");
            when others => assert false report "Excessive data in RMAP reply" severity failure;
        end case;
        chk.update(v8);
        i := i + 1;
    end loop;
  end procedure;

  variable src_index, dst_index : integer;
  variable exclude_index        : integer_vector (0 to 0);
  variable src_link, dst_link   : actor_t;

  type packet_array0_t is array (0 to 5) of integer_array_t;
  type packet_array_t is array (0 to 5) of packet_array0_t;

  variable txpackets, rxpackets : packet_array_t;
  variable txpacket, rxpacket   : integer_array_t;
  variable subscribers          : actor_vec_t (0 to 5);

  impure function hex_image(v : integer_array_t) return string is
    variable l : line;
  begin
    for i in 0 to v.length - 1 loop
      write(l, to_hstring(to_unsigned(get(v, i), 8)));
    end loop;  -- i
    return l.all;
  end function;
  begin  -- process sim
    test_runner_setup(runner, runner_cfg);
    rnd.InitSeed(rnd'instance_name);
    testen <= '0';
    while test_suite loop
      if run("Link up test") then
        for i in 0 to 5 loop
          msg := new_msg(spw_type_linkctl);
          push(msg, std_logic_vector'("110"));
          send(net, find("e" & to_string(i)), msg);
          delete(msg);
        end loop;  -- i
        rst <= '1';
        wait for 20*T;
        rst <= '0';
        wait for 100 us;
        for i in 0 to 5 loop
          msg        := new_msg(spw_type_linkstatus);
          send(net, find("e" & to_string(i)), msg);
          receive_reply(net, msg, msgr);
          linkstatus := pop(msgr);
          check_equal(linkstatus, std_logic_vector'("001"), result("Link[" & to_string(i) & "] running"));
          delete(msg);
        end loop;  -- i
      elsif run("Simple transfer") then
        enable_link(find("e0"));
        enable_link(find("e1"));

        subscribe(self, find("e1"));

        for n in 0 to 9 loop
          msg         := new_msg(spw_type_txdata);
          test_packet := new_1d;

          push(msg, std_logic_vector'(x"02"));
          for i in 0 to rnd.RandInt(0, 63) loop
            d8 := std_logic_vector(to_unsigned(rnd.RandInt(0, 255), 8));
            append(test_packet, to_integer(unsigned(d8)));
            push(msg, d8);
          end loop;  -- i

          send(net, find("e0"), msg); delete(msg);
          receive(net, self, msg);

          for i in 0 to length(test_packet)-1 loop
            check(not is_empty(msg));
            d8 := pop(msg);
            check_equal(d8, get(test_packet, i));
          end loop;
          check(is_empty(msg));
          delete(msg);
          deallocate(test_packet);
        end loop;  -- n
      elsif run("RMAP CRC8 test") then
        crc_test;
      elsif run("RMAP packet") then
        rmap_hdr.init;
        rmap_hdr.append(x"54");
        rmap_hdr.append(x"01");
        rmap_hdr.append(
          "01" &
          "0011" &
          "00"
          );
        rmap_hdr.append(x"57");
        rmap_hdr.append(x"76");
        rmap_hdr.append(x"00");
        rmap_hdr.append(x"05");
        rmap_hdr.append(x"00");
        rmap_hdr.append(x"00");
        rmap_hdr.append(x"00");
        rmap_hdr.append(x"20");
        rmap_hdr.append(x"00");
        rmap_hdr.append(x"00");
        rmap_hdr.append(x"00");
        rmap_hdr.append(x"10");
        rmap_hdr.finalize;

        check_equal(rmap_hdr.length, 16);
        check_equal(rmap_hdr.get(rmap_hdr.length-1), std_logic_vector'(x"83"));
      elsif run("RMAP read 0x00000800") then
        enable_link(find("e0"));
        subscribe(self, find("e0"));
        rmap_read_32(find("e0"), self, x"00000800", d);
        check_equal(d, std_logic_vector'(x"40224950"), "Device code ID register");
      elsif run("RMAP Routing table R/W") then
        enable_link(find("e0"));
        subscribe(self, find("e0"));
        test_packet := new_1d;
        for la in 16#20# to 16#fe# loop
            a := std_logic_vector(to_unsigned(la*4, 32));
            d := rnd.RandSlv(size => 32);
            append(test_packet, to_integer(unsigned(d(31 downto 16))));
            append(test_packet, to_integer(unsigned(d(15 downto 0))));
            rmap_write_32(find("e0"), self, a, d);
        end loop;
        for la in 16#20# to 16#fe# loop
            a := std_logic_vector(to_unsigned(la*4, 32));
            rmap_read_32(find("e0"), self, a, d);
            r := std_logic_vector(
                to_unsigned(get(test_packet, 2*(la - 16#20#) + 0), 16) &
                to_unsigned(get(test_packet, 2*(la - 16#20#) + 1), 16));
            debug("At " & hex_image(std_logic_vector(to_unsigned(la, 8))) & " :: " &
                " written = " & hex_image(r) & ", read = " & hex_image(d));
            check_equal(d, r,
                "Value at address " & hex_image(std_logic_vector(to_unsigned(la, 8))));
        end loop;
        r := std_logic_vector(
                to_unsigned(get(test_packet, 0), 16) &
                to_unsigned(get(test_packet, 1), 16));
        r := r xor x"00ff00ff";
        rmap_write_32(find("e0"), self, x"00000080", r, x"00ff00ff", d);
        rmap_read_32(find("e0"), self, x"00000080", d);
        check_equal(r, d, "Table entry after read-modify-write");
      elsif run("RMAP Routing table") then

        for tier in 0 to 63 loop

          src_index        := rnd.RandInt(0, 5);
          exclude_index(0) := src_index;
          dst_index        := rnd.RandInt(0, 5, exclude_index);

          src_link := find("e" & integer'image(src_index));
          dst_link := find("e" & integer'image(dst_index));

          log("Using comm [" & integer'image(src_index) & "] -> [" & integer'image(dst_index) & "]");
          enable_link(src_link);
          enable_link(dst_link);
          subscribe(self, src_link);

          d                := (others => '0');
          d(dst_index + 1) := '1';
          rmap_write_32(src_link, self, x"00000080", d);
          unsubscribe(self, src_link);

          subscribe(self, dst_link);
          test_packet := new_1d;
          append(test_packet, 16#20#);  -- Logical address
          for i in 0 to 15 loop
            append(test_packet, rnd.RandInt(0, 255));
          end loop;  -- i
          msg := new_msg(spw_type_txdata);
          for i in 0 to test_packet.length - 1 loop
            push(msg, std_logic_vector(to_unsigned(get(test_packet, i), 8)));
          end loop;  -- i
          send(net, src_link, msg);

          receive(net, self, msg);
          check(not is_empty(msg), "Non-empty message");
          for i in 0 to test_packet.length - 1 loop
            d8 := pop(msg);
            check(unsigned(d8) = get(test_packet, i), "Packet byte #" & integer'image(i));
          end loop;  -- i
          check(is_empty(msg), "No unexpected bytes");
          delete(msg);
          deallocate(test_packet);
          unsubscribe(self, dst_link);
        end loop;  -- tier
      elsif run("Stress test") then
        rst <= '1';
        for link_idx in 0 to N_PORTS-1 loop
             msg := new_msg(spw_type_linkctl);
             push(msg, std_logic_vector'("110"));
             send(net, find("e" & integer'image(link_idx)), msg);
             delete(msg);
        end loop;  -- link_idx
        rst <= '0';

        for link_idx in 0 to N_PORTS-1 loop
          msg := new_msg(spw_type_pollrunning);
          send(net, find("e" & integer'image(link_idx)), msg);
          receive_reply(net, msg, msgr);
          check(message_type(msgr) = spw_type_pollrunning_reply);
        end loop;  -- link_idx

        for link_idx in 0 to N_PORTS-1 loop
          subscribers(link_idx) := new_actor("sub" & integer'image(link_idx));
          subscribe(subscribers(link_idx), find("e" & integer'image(link_idx)));
        end loop;  -- link_idx

        for src in 0 to N_PORTS-1 loop
          for dst in 0 to N_PORTS-1 loop
            txpackets(src)(dst) := new_1d;
            append(txpackets(src)(dst), dst + 1);  -- physical addressing
            append(txpackets(src)(dst), src + 1);  -- keep source port number
            for num in 0 to rnd.RandInt(0, 15) loop
              append(txpackets(src)(dst), rnd.RandInt(0, 255));
            end loop;  -- num
            msg := new_msg(spw_type_delay);
            push(msg, T * rnd.RandInt(1, 100));
            send(net, find("e" & integer'image(src)), msg);
            delete(msg);
            msg := new_msg(spw_type_txdata);
            for i in 0 to txpackets(src)(dst).length - 1 loop
              push(msg, std_logic_vector(to_unsigned(get(txpackets(src)(dst), i), 8)));
            end loop;  -- i
            log("Sending packet [" & integer'image(src) & "] -> [" & integer'image(dst) & "] = " & hex_image(txpackets(src)(dst)));
            send(net, find("e" & integer'image(src)), msg);
            delete(msg);
          end loop;  -- dst
        end loop;  -- src

        for src in 0 to N_PORTS-1 loop
          for dst in 0 to N_PORTS-1 loop
            rxpackets(src)(dst) := new_1d;
            receive(net, subscribers(src), msg);
            while not is_empty(msg) loop
              d8 := pop(msg);
              append(rxpackets(src)(dst), to_integer(unsigned(d8)));
            end loop;
          end loop;  -- dst
        end loop;  -- src

        for src in 0 to N_PORTS-1 loop
          for dst in 0 to N_PORTS-1 loop
            txpacket  := txpackets(src)(dst);
            dst_index := get(txpacket, 0) - 1;
            src_index := get(txpacket, 1) - 1;
            for src1 in 0 to N_PORTS-1 loop
              if get(rxpackets(dst_index)(src1), 0) = src_index + 1 then
                rxpacket := rxpackets(dst_index)(src1);
                debug("[ " & integer'image(src) & " -> " & integer'image(dst) & "] " &
                      boolean'image(txpacket.length = rxpacket.length + 1) & " " &
                      "TX = " & hex_image(txpacket) & ", RX = " & hex_image(rxpacket));
                check_equal(txpacket.length, rxpacket.length + 1);  -- 1 byte for
                                                                    -- physical addressing
                for i in 0 to rxpacket.length - 1 loop
                  check_equal(get(txpacket, i+1), get(rxpacket, i));
                end loop;  -- i
              end if;
            end loop;  -- src1
          end loop;  -- dst
        end loop;  -- src

      elsif run("Test memory interface") then
        rst <= '1';
        testen <= '1';
        wait for 20*T;
        rst <= '0';
        wait for 100*T;
        msg := new_msg(test_mem_write);
        push(msg, 16#00000000#);
        push(msg, 16#ab#);
        push(msg, 16#cd#);
        push(msg, 16#12#);
        push(msg, 16#34#);
        send(net, find("mem0"), msg);
        delete(msg);
        wait for 100*T;
        msg := new_msg(test_mem_read);
        push(msg, 16#00000000#);
        push(msg, 4);
        send(net, find("mem0"), msg);
        receive_reply(net, msg, msgr);
        for i in 0 to 3 loop
            d8 := std_logic_vector(to_unsigned(pop_integer(msgr), 8));
            log("Reply is " & hex_image(d8));
        end loop;
      end if;
    end loop;
    test_runner_cleanup(runner);
    wait;
  end process sim;

  test_runner_watchdog(runner, 10 ms);
end architecture behav;

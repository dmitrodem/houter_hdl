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

library osvvm;
use osvvm.RandomPkg.all;

entity tb_router is
  generic (
    runner_cfg : string);
end entity tb_router;

architecture behav of tb_router is

  constant sysfreq   : real := 100.0e6;
  constant txclkfreq : real := sysfreq;

  constant T : time := (1.0/sysfreq) * (1.0e3 ms);

  -- [[[cog
  -- for i in range(0, n-1):
  --   print(f'constant e{i} : actor_t := find("e{i}");')
  -- ]]]
  constant e0 : actor_t := find("e0");
  constant e1 : actor_t := find("e1");
  constant e2 : actor_t := find("e2");
  constant e3 : actor_t := find("e3");
  constant e4 : actor_t := find("e4");
  constant e5 : actor_t := find("e5");
  -- [[[end]]]

  signal clk          : std_logic;
  signal rst          : std_logic;
  -- [[[cog
  -- for i in range(0, n-1):
  --   print(f"signal autostart_{i}  : std_logic := '0';")
  --   print(f"signal linkstart_{i}  : std_logic := '0';")
  --   print(f"signal linkdis_{i}    : std_logic := '0';")
  --   print(f"signal txdivcnt_{i}   : std_logic_vector (7 downto 0) := (others => '0');")
  --   print(f"signal tick_in_{i}    : std_logic := '0';")
  --   print(f"signal ctrl_in_{i}    : std_logic_vector (1 downto 0) := (others => '0');")
  --   print(f"signal time_in_{i}    : std_logic_vector (5 downto 0) := (others => '0');")
  --   print(f"signal txwrite_{i}    : std_logic := '0';")
  --   print(f"signal txflag_{i}     : std_logic := '0';")
  --   print(f"signal txdata_{i}     : std_logic_vector (7 downto 0) := (others => '0');")
  --   print(f"signal txrdy_{i}      : std_logic := '0';")
  --   print(f"signal txhalff_{i}    : std_logic := '0';")
  --   print(f"signal tick_out_{i}   : std_logic := '0';")
  --   print(f"signal ctrl_out_{i}   : std_logic_vector (1 downto 0) := (others => '0');")
  --   print(f"signal time_out_{i}   : std_logic_vector (5 downto 0) := (others => '0');")
  --   print(f"signal rxvalid_{i}    : std_logic := '0';")
  --   print(f"signal rxhalff_{i}    : std_logic := '0';")
  --   print(f"signal rxflag_{i}     : std_logic := '0';")
  --   print(f"signal rxdata_{i}     : std_logic_vector (7 downto 0) := (others => '0');")
  --   print(f"signal rxread_{i}     : std_logic := '0';")
  --   print(f"signal started_{i}    : std_logic := '0';")
  --   print(f"signal connecting_{i} : std_logic := '0';")
  --   print(f"signal running_{i}    : std_logic := '0';")
  --   print(f"signal errdisc_{i}    : std_logic := '0';")
  --   print(f"signal errpar_{i}     : std_logic := '0';")
  --   print(f"signal erresc_{i}     : std_logic := '0';")
  --   print(f"signal errcred_{i}    : std_logic := '0';")
  --   print(f"signal spw_di_{i}     : std_logic := '0';")
  --   print(f"signal spw_si_{i}     : std_logic := '0';")
  --   print(f"signal spw_do_{i}     : std_logic := '0';")
  --   print(f"signal spw_so_{i}     : std_logic := '0';")
  -- ]]]
  signal autostart_0  : std_logic                     := '0';
  signal linkstart_0  : std_logic                     := '0';
  signal linkdis_0    : std_logic                     := '0';
  signal txdivcnt_0   : std_logic_vector (7 downto 0) := (others => '0');
  signal tick_in_0    : std_logic                     := '0';
  signal ctrl_in_0    : std_logic_vector (1 downto 0) := (others => '0');
  signal time_in_0    : std_logic_vector (5 downto 0) := (others => '0');
  signal txwrite_0    : std_logic                     := '0';
  signal txflag_0     : std_logic                     := '0';
  signal txdata_0     : std_logic_vector (7 downto 0) := (others => '0');
  signal txrdy_0      : std_logic                     := '0';
  signal txhalff_0    : std_logic                     := '0';
  signal tick_out_0   : std_logic                     := '0';
  signal ctrl_out_0   : std_logic_vector (1 downto 0) := (others => '0');
  signal time_out_0   : std_logic_vector (5 downto 0) := (others => '0');
  signal rxvalid_0    : std_logic                     := '0';
  signal rxhalff_0    : std_logic                     := '0';
  signal rxflag_0     : std_logic                     := '0';
  signal rxdata_0     : std_logic_vector (7 downto 0) := (others => '0');
  signal rxread_0     : std_logic                     := '0';
  signal started_0    : std_logic                     := '0';
  signal connecting_0 : std_logic                     := '0';
  signal running_0    : std_logic                     := '0';
  signal errdisc_0    : std_logic                     := '0';
  signal errpar_0     : std_logic                     := '0';
  signal erresc_0     : std_logic                     := '0';
  signal errcred_0    : std_logic                     := '0';
  signal spw_di_0     : std_logic                     := '0';
  signal spw_si_0     : std_logic                     := '0';
  signal spw_do_0     : std_logic                     := '0';
  signal spw_so_0     : std_logic                     := '0';
  signal autostart_1  : std_logic                     := '0';
  signal linkstart_1  : std_logic                     := '0';
  signal linkdis_1    : std_logic                     := '0';
  signal txdivcnt_1   : std_logic_vector (7 downto 0) := (others => '0');
  signal tick_in_1    : std_logic                     := '0';
  signal ctrl_in_1    : std_logic_vector (1 downto 0) := (others => '0');
  signal time_in_1    : std_logic_vector (5 downto 0) := (others => '0');
  signal txwrite_1    : std_logic                     := '0';
  signal txflag_1     : std_logic                     := '0';
  signal txdata_1     : std_logic_vector (7 downto 0) := (others => '0');
  signal txrdy_1      : std_logic                     := '0';
  signal txhalff_1    : std_logic                     := '0';
  signal tick_out_1   : std_logic                     := '0';
  signal ctrl_out_1   : std_logic_vector (1 downto 0) := (others => '0');
  signal time_out_1   : std_logic_vector (5 downto 0) := (others => '0');
  signal rxvalid_1    : std_logic                     := '0';
  signal rxhalff_1    : std_logic                     := '0';
  signal rxflag_1     : std_logic                     := '0';
  signal rxdata_1     : std_logic_vector (7 downto 0) := (others => '0');
  signal rxread_1     : std_logic                     := '0';
  signal started_1    : std_logic                     := '0';
  signal connecting_1 : std_logic                     := '0';
  signal running_1    : std_logic                     := '0';
  signal errdisc_1    : std_logic                     := '0';
  signal errpar_1     : std_logic                     := '0';
  signal erresc_1     : std_logic                     := '0';
  signal errcred_1    : std_logic                     := '0';
  signal spw_di_1     : std_logic                     := '0';
  signal spw_si_1     : std_logic                     := '0';
  signal spw_do_1     : std_logic                     := '0';
  signal spw_so_1     : std_logic                     := '0';
  signal autostart_2  : std_logic                     := '0';
  signal linkstart_2  : std_logic                     := '0';
  signal linkdis_2    : std_logic                     := '0';
  signal txdivcnt_2   : std_logic_vector (7 downto 0) := (others => '0');
  signal tick_in_2    : std_logic                     := '0';
  signal ctrl_in_2    : std_logic_vector (1 downto 0) := (others => '0');
  signal time_in_2    : std_logic_vector (5 downto 0) := (others => '0');
  signal txwrite_2    : std_logic                     := '0';
  signal txflag_2     : std_logic                     := '0';
  signal txdata_2     : std_logic_vector (7 downto 0) := (others => '0');
  signal txrdy_2      : std_logic                     := '0';
  signal txhalff_2    : std_logic                     := '0';
  signal tick_out_2   : std_logic                     := '0';
  signal ctrl_out_2   : std_logic_vector (1 downto 0) := (others => '0');
  signal time_out_2   : std_logic_vector (5 downto 0) := (others => '0');
  signal rxvalid_2    : std_logic                     := '0';
  signal rxhalff_2    : std_logic                     := '0';
  signal rxflag_2     : std_logic                     := '0';
  signal rxdata_2     : std_logic_vector (7 downto 0) := (others => '0');
  signal rxread_2     : std_logic                     := '0';
  signal started_2    : std_logic                     := '0';
  signal connecting_2 : std_logic                     := '0';
  signal running_2    : std_logic                     := '0';
  signal errdisc_2    : std_logic                     := '0';
  signal errpar_2     : std_logic                     := '0';
  signal erresc_2     : std_logic                     := '0';
  signal errcred_2    : std_logic                     := '0';
  signal spw_di_2     : std_logic                     := '0';
  signal spw_si_2     : std_logic                     := '0';
  signal spw_do_2     : std_logic                     := '0';
  signal spw_so_2     : std_logic                     := '0';
  signal autostart_3  : std_logic                     := '0';
  signal linkstart_3  : std_logic                     := '0';
  signal linkdis_3    : std_logic                     := '0';
  signal txdivcnt_3   : std_logic_vector (7 downto 0) := (others => '0');
  signal tick_in_3    : std_logic                     := '0';
  signal ctrl_in_3    : std_logic_vector (1 downto 0) := (others => '0');
  signal time_in_3    : std_logic_vector (5 downto 0) := (others => '0');
  signal txwrite_3    : std_logic                     := '0';
  signal txflag_3     : std_logic                     := '0';
  signal txdata_3     : std_logic_vector (7 downto 0) := (others => '0');
  signal txrdy_3      : std_logic                     := '0';
  signal txhalff_3    : std_logic                     := '0';
  signal tick_out_3   : std_logic                     := '0';
  signal ctrl_out_3   : std_logic_vector (1 downto 0) := (others => '0');
  signal time_out_3   : std_logic_vector (5 downto 0) := (others => '0');
  signal rxvalid_3    : std_logic                     := '0';
  signal rxhalff_3    : std_logic                     := '0';
  signal rxflag_3     : std_logic                     := '0';
  signal rxdata_3     : std_logic_vector (7 downto 0) := (others => '0');
  signal rxread_3     : std_logic                     := '0';
  signal started_3    : std_logic                     := '0';
  signal connecting_3 : std_logic                     := '0';
  signal running_3    : std_logic                     := '0';
  signal errdisc_3    : std_logic                     := '0';
  signal errpar_3     : std_logic                     := '0';
  signal erresc_3     : std_logic                     := '0';
  signal errcred_3    : std_logic                     := '0';
  signal spw_di_3     : std_logic                     := '0';
  signal spw_si_3     : std_logic                     := '0';
  signal spw_do_3     : std_logic                     := '0';
  signal spw_so_3     : std_logic                     := '0';
  signal autostart_4  : std_logic                     := '0';
  signal linkstart_4  : std_logic                     := '0';
  signal linkdis_4    : std_logic                     := '0';
  signal txdivcnt_4   : std_logic_vector (7 downto 0) := (others => '0');
  signal tick_in_4    : std_logic                     := '0';
  signal ctrl_in_4    : std_logic_vector (1 downto 0) := (others => '0');
  signal time_in_4    : std_logic_vector (5 downto 0) := (others => '0');
  signal txwrite_4    : std_logic                     := '0';
  signal txflag_4     : std_logic                     := '0';
  signal txdata_4     : std_logic_vector (7 downto 0) := (others => '0');
  signal txrdy_4      : std_logic                     := '0';
  signal txhalff_4    : std_logic                     := '0';
  signal tick_out_4   : std_logic                     := '0';
  signal ctrl_out_4   : std_logic_vector (1 downto 0) := (others => '0');
  signal time_out_4   : std_logic_vector (5 downto 0) := (others => '0');
  signal rxvalid_4    : std_logic                     := '0';
  signal rxhalff_4    : std_logic                     := '0';
  signal rxflag_4     : std_logic                     := '0';
  signal rxdata_4     : std_logic_vector (7 downto 0) := (others => '0');
  signal rxread_4     : std_logic                     := '0';
  signal started_4    : std_logic                     := '0';
  signal connecting_4 : std_logic                     := '0';
  signal running_4    : std_logic                     := '0';
  signal errdisc_4    : std_logic                     := '0';
  signal errpar_4     : std_logic                     := '0';
  signal erresc_4     : std_logic                     := '0';
  signal errcred_4    : std_logic                     := '0';
  signal spw_di_4     : std_logic                     := '0';
  signal spw_si_4     : std_logic                     := '0';
  signal spw_do_4     : std_logic                     := '0';
  signal spw_so_4     : std_logic                     := '0';
  signal autostart_5  : std_logic                     := '0';
  signal linkstart_5  : std_logic                     := '0';
  signal linkdis_5    : std_logic                     := '0';
  signal txdivcnt_5   : std_logic_vector (7 downto 0) := (others => '0');
  signal tick_in_5    : std_logic                     := '0';
  signal ctrl_in_5    : std_logic_vector (1 downto 0) := (others => '0');
  signal time_in_5    : std_logic_vector (5 downto 0) := (others => '0');
  signal txwrite_5    : std_logic                     := '0';
  signal txflag_5     : std_logic                     := '0';
  signal txdata_5     : std_logic_vector (7 downto 0) := (others => '0');
  signal txrdy_5      : std_logic                     := '0';
  signal txhalff_5    : std_logic                     := '0';
  signal tick_out_5   : std_logic                     := '0';
  signal ctrl_out_5   : std_logic_vector (1 downto 0) := (others => '0');
  signal time_out_5   : std_logic_vector (5 downto 0) := (others => '0');
  signal rxvalid_5    : std_logic                     := '0';
  signal rxhalff_5    : std_logic                     := '0';
  signal rxflag_5     : std_logic                     := '0';
  signal rxdata_5     : std_logic_vector (7 downto 0) := (others => '0');
  signal rxread_5     : std_logic                     := '0';
  signal started_5    : std_logic                     := '0';
  signal connecting_5 : std_logic                     := '0';
  signal running_5    : std_logic                     := '0';
  signal errdisc_5    : std_logic                     := '0';
  signal errpar_5     : std_logic                     := '0';
  signal erresc_5     : std_logic                     := '0';
  signal errcred_5    : std_logic                     := '0';
  signal spw_di_5     : std_logic                     := '0';
  signal spw_si_5     : std_logic                     := '0';
  signal spw_do_5     : std_logic                     := '0';
  signal spw_so_5     : std_logic                     := '0';
  -- [[[end]]]


begin  -- architecture behav
  -- link{i}: entity work.spwstream
  --   generic map (
  --     sysfreq         => sysfreq,
  --     txclkfreq       => txclkfreq,
  --     rximpl          => impl_generic,
  --     rxchunk         => 1,
  --     tximpl          => impl_generic,
  --     rxfifosize_bits => 11,
  --     txfifosize_bits => 11)
  --   port map (
  --     clk        => clk,
  --     rxclk      => clk,
  --     txclk      => clk,
  --     rst        => rst,
  --     autostart  => autostart_{i},
  --     linkstart  => linkstart_{i},
  --     linkdis    => linkdis_{i},
  --     txdivcnt   => txdivcnt_{i},
  --     tick_in    => tick_in_{i},
  --     ctrl_in    => ctrl_in_{i},
  --     time_in    => time_in_{i},
  --     txwrite    => txwrite_{i},
  --     txflag     => txflag_{i},
  --     txdata     => txdata_{i},
  --     txrdy      => txrdy_{i},
  --     txhalff    => txhalff_{i},
  --     tick_out   => tick_out_{i},
  --     ctrl_out   => ctrl_out_{i},
  --     time_out   => time_out_{i},
  --     rxvalid    => rxvalid_{i},
  --     rxhalff    => rxhalff_{i},
  --     rxflag     => rxflag_{i},
  --     rxdata     => rxdata_{i},
  --     rxread     => rxread_{i},
  --     started    => started_{i},
  --     connecting => connecting_{i},
  --     running    => running_{i},
  --     errdisc    => errdisc_{i},
  --     errpar     => errpar_{i},
  --     erresc     => erresc_{i},
  --     errcred    => errcred_{i},
  --     spw_di     => spw_di_{i},
  --     spw_si     => spw_si_{i},
  --     spw_do     => spw_do_{i},
  --     spw_so     => spw_so_{i});

  -- [[[cog
  -- tmpl = """
  -- link{i}: entity work.spw_actor
  -- generic map (
  --   name      => "e{i}",
  --   sysfreq   => sysfreq,
  --   txclkfreq => txclkfreq)
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
  link0 : entity work.spw_actor
    generic map (
      name      => "e0",
      sysfreq   => sysfreq,
      txclkfreq => txclkfreq)
    port map (
      clk    => clk,
      rst    => rst,
      spw_di => spw_di_0,
      spw_si => spw_si_0,
      spw_do => spw_do_0,
      spw_so => spw_so_0);
  link1 : entity work.spw_actor
    generic map (
      name      => "e1",
      sysfreq   => sysfreq,
      txclkfreq => txclkfreq)
    port map (
      clk    => clk,
      rst    => rst,
      spw_di => spw_di_1,
      spw_si => spw_si_1,
      spw_do => spw_do_1,
      spw_so => spw_so_1);
  link2 : entity work.spw_actor
    generic map (
      name      => "e2",
      sysfreq   => sysfreq,
      txclkfreq => txclkfreq)
    port map (
      clk    => clk,
      rst    => rst,
      spw_di => spw_di_2,
      spw_si => spw_si_2,
      spw_do => spw_do_2,
      spw_so => spw_so_2);
  link3 : entity work.spw_actor
    generic map (
      name      => "e3",
      sysfreq   => sysfreq,
      txclkfreq => txclkfreq)
    port map (
      clk    => clk,
      rst    => rst,
      spw_di => spw_di_3,
      spw_si => spw_si_3,
      spw_do => spw_do_3,
      spw_so => spw_so_3);
  link4 : entity work.spw_actor
    generic map (
      name      => "e4",
      sysfreq   => sysfreq,
      txclkfreq => txclkfreq)
    port map (
      clk    => clk,
      rst    => rst,
      spw_di => spw_di_4,
      spw_si => spw_si_4,
      spw_do => spw_do_4,
      spw_so => spw_so_4);
  link5 : entity work.spw_actor
    generic map (
      name      => "e5",
      sysfreq   => sysfreq,
      txclkfreq => txclkfreq)
    port map (
      clk    => clk,
      rst    => rst,
      spw_di => spw_di_5,
      spw_si => spw_si_5,
      spw_do => spw_do_5,
      spw_so => spw_so_5);
  -- [[[end]]]

  router0 : entity work.SpaceWireRouterIP
    port map (
      clock                       => clk,
      transmitClock               => clk,
      receiveClock                => clk,
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
      busMasterUserAcknowledgeOut => open);

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

  sim : process is
    procedure ensure (
      signal s   : in std_logic;
      constant v : in std_logic) is
    begin  -- procedure ensure
      if s /= v then
        wait until s = v;
      end if;
    end procedure ensure;

    variable rnd     : RandomPType;
    variable packets : integer_array_t;
    variable d       : std_logic_vector (31 downto 0);
    variable d8      : std_logic_vector (7 downto 0);
    variable n       : integer;
    variable crc     : crc_t;

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
  variable self        : actor_t         := new_actor("checker");
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
    variable v32     : std_logic_vector (31 downto 0);
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

  variable src_index, dst_index : integer;
  variable exclude_index        : integer_vector (0 to 0);
  variable src_link, dst_link   : actor_t;

  type packet_array0_t is array (0 to 5) of integer_array_t;
  type packet_array_t is array (0 to 5) of packet_array0_t;

  variable txpackets, rxpackets : packet_array_t;
  variable txpacket, rxpacket   : integer_array_t;
  variable subscribers          : actor_vec_t (0 to 5);
  variable ll                   : line;

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
    packets := new_1d(0, 9, false);
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
        for link_idx in 0 to 5 loop
          enable_link(find("e" & integer'image(link_idx)));
        end loop;  -- link_idx

        for link_idx in 0 to 5 loop
          subscribers(link_idx) := new_actor("sub" & integer'image(link_idx));
          subscribe(subscribers(link_idx), find("e" & integer'image(link_idx)));
        end loop;  -- link_idx

        for src in 0 to 5 loop
          for dst in 0 to 5 loop
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
            send(net, find("e" & integer'image(src)), msg);
            delete(msg);
          end loop;  -- dst
        end loop;  -- src

        for src in 0 to 5 loop
          for dst in 0 to 5 loop
            rxpackets(src)(dst) := new_1d;
            receive(net, subscribers(src), msg);
            while not is_empty(msg) loop
              d8 := pop(msg);
              append(rxpackets(src)(dst), to_integer(unsigned(d8)));
            end loop;
          end loop;  -- dst
        end loop;  -- src

        for src in 0 to 5 loop
          for dst in 0 to 5 loop
            txpacket  := txpackets(src)(dst);
            dst_index := get(txpacket, 0) - 1;
            src_index := get(txpacket, 1) - 1;
            for src1 in 0 to 5 loop
              if get(rxpackets(dst_index)(src1), 0) = src_index + 1 then
                rxpacket := rxpackets(dst_index)(src1);
                log("[ " & integer'image(src) & " -> " & integer'image(dst) & "] " &
                    boolean'image(txpacket.length = rxpacket.length + 1) & " " &
                    "TX = " & hex_image(txpacket) & ", RX = " & hex_image(rxpacket));
              -- check_equal(txpacket.length, rxpacket.length + 1);  -- 1 byte for
              --                                                     -- physical addressing
              -- for i in 0 to rxpacket.length - 1 loop
              --   check_equal(get(txpacket, i+1), get(rxpacket, i));
              -- end loop;  -- i
              end if;
            end loop;  -- src1
          end loop;  -- dst
        end loop;  -- src

      end if;
    end loop;
    test_runner_cleanup(runner);
    wait;
  end process sim;

  test_runner_watchdog(runner, 10 ms);
end architecture behav;

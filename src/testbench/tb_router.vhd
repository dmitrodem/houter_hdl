-- [[[cog
-- n = int(nports) + 1
-- ]]]
-- [[[end]]]

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.spwpkg.all;
use work.rmap_crc.all;

library vunit_lib;
context vunit_lib.vunit_context;

library osvvm;
use osvvm.RandomPkg.all;

entity tb_router is
  generic (
    runner_cfg : string);
end entity tb_router;

architecture behav of tb_router is

  constant sysfreq : real := 100.0e6;
  constant txclkfreq : real := sysfreq;

  constant T : time := (1.0/sysfreq) * 1e3ms;

  signal clk        : std_logic;
  signal rst        : std_logic;
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
  signal autostart_0  : std_logic := '0';
  signal linkstart_0  : std_logic := '0';
  signal linkdis_0    : std_logic := '0';
  signal txdivcnt_0   : std_logic_vector (7 downto 0) := (others => '0');
  signal tick_in_0    : std_logic := '0';
  signal ctrl_in_0    : std_logic_vector (1 downto 0) := (others => '0');
  signal time_in_0    : std_logic_vector (5 downto 0) := (others => '0');
  signal txwrite_0    : std_logic := '0';
  signal txflag_0     : std_logic := '0';
  signal txdata_0     : std_logic_vector (7 downto 0) := (others => '0');
  signal txrdy_0      : std_logic := '0';
  signal txhalff_0    : std_logic := '0';
  signal tick_out_0   : std_logic := '0';
  signal ctrl_out_0   : std_logic_vector (1 downto 0) := (others => '0');
  signal time_out_0   : std_logic_vector (5 downto 0) := (others => '0');
  signal rxvalid_0    : std_logic := '0';
  signal rxhalff_0    : std_logic := '0';
  signal rxflag_0     : std_logic := '0';
  signal rxdata_0     : std_logic_vector (7 downto 0) := (others => '0');
  signal rxread_0     : std_logic := '0';
  signal started_0    : std_logic := '0';
  signal connecting_0 : std_logic := '0';
  signal running_0    : std_logic := '0';
  signal errdisc_0    : std_logic := '0';
  signal errpar_0     : std_logic := '0';
  signal erresc_0     : std_logic := '0';
  signal errcred_0    : std_logic := '0';
  signal spw_di_0     : std_logic := '0';
  signal spw_si_0     : std_logic := '0';
  signal spw_do_0     : std_logic := '0';
  signal spw_so_0     : std_logic := '0';
  signal autostart_1  : std_logic := '0';
  signal linkstart_1  : std_logic := '0';
  signal linkdis_1    : std_logic := '0';
  signal txdivcnt_1   : std_logic_vector (7 downto 0) := (others => '0');
  signal tick_in_1    : std_logic := '0';
  signal ctrl_in_1    : std_logic_vector (1 downto 0) := (others => '0');
  signal time_in_1    : std_logic_vector (5 downto 0) := (others => '0');
  signal txwrite_1    : std_logic := '0';
  signal txflag_1     : std_logic := '0';
  signal txdata_1     : std_logic_vector (7 downto 0) := (others => '0');
  signal txrdy_1      : std_logic := '0';
  signal txhalff_1    : std_logic := '0';
  signal tick_out_1   : std_logic := '0';
  signal ctrl_out_1   : std_logic_vector (1 downto 0) := (others => '0');
  signal time_out_1   : std_logic_vector (5 downto 0) := (others => '0');
  signal rxvalid_1    : std_logic := '0';
  signal rxhalff_1    : std_logic := '0';
  signal rxflag_1     : std_logic := '0';
  signal rxdata_1     : std_logic_vector (7 downto 0) := (others => '0');
  signal rxread_1     : std_logic := '0';
  signal started_1    : std_logic := '0';
  signal connecting_1 : std_logic := '0';
  signal running_1    : std_logic := '0';
  signal errdisc_1    : std_logic := '0';
  signal errpar_1     : std_logic := '0';
  signal erresc_1     : std_logic := '0';
  signal errcred_1    : std_logic := '0';
  signal spw_di_1     : std_logic := '0';
  signal spw_si_1     : std_logic := '0';
  signal spw_do_1     : std_logic := '0';
  signal spw_so_1     : std_logic := '0';
  signal autostart_2  : std_logic := '0';
  signal linkstart_2  : std_logic := '0';
  signal linkdis_2    : std_logic := '0';
  signal txdivcnt_2   : std_logic_vector (7 downto 0) := (others => '0');
  signal tick_in_2    : std_logic := '0';
  signal ctrl_in_2    : std_logic_vector (1 downto 0) := (others => '0');
  signal time_in_2    : std_logic_vector (5 downto 0) := (others => '0');
  signal txwrite_2    : std_logic := '0';
  signal txflag_2     : std_logic := '0';
  signal txdata_2     : std_logic_vector (7 downto 0) := (others => '0');
  signal txrdy_2      : std_logic := '0';
  signal txhalff_2    : std_logic := '0';
  signal tick_out_2   : std_logic := '0';
  signal ctrl_out_2   : std_logic_vector (1 downto 0) := (others => '0');
  signal time_out_2   : std_logic_vector (5 downto 0) := (others => '0');
  signal rxvalid_2    : std_logic := '0';
  signal rxhalff_2    : std_logic := '0';
  signal rxflag_2     : std_logic := '0';
  signal rxdata_2     : std_logic_vector (7 downto 0) := (others => '0');
  signal rxread_2     : std_logic := '0';
  signal started_2    : std_logic := '0';
  signal connecting_2 : std_logic := '0';
  signal running_2    : std_logic := '0';
  signal errdisc_2    : std_logic := '0';
  signal errpar_2     : std_logic := '0';
  signal erresc_2     : std_logic := '0';
  signal errcred_2    : std_logic := '0';
  signal spw_di_2     : std_logic := '0';
  signal spw_si_2     : std_logic := '0';
  signal spw_do_2     : std_logic := '0';
  signal spw_so_2     : std_logic := '0';
  signal autostart_3  : std_logic := '0';
  signal linkstart_3  : std_logic := '0';
  signal linkdis_3    : std_logic := '0';
  signal txdivcnt_3   : std_logic_vector (7 downto 0) := (others => '0');
  signal tick_in_3    : std_logic := '0';
  signal ctrl_in_3    : std_logic_vector (1 downto 0) := (others => '0');
  signal time_in_3    : std_logic_vector (5 downto 0) := (others => '0');
  signal txwrite_3    : std_logic := '0';
  signal txflag_3     : std_logic := '0';
  signal txdata_3     : std_logic_vector (7 downto 0) := (others => '0');
  signal txrdy_3      : std_logic := '0';
  signal txhalff_3    : std_logic := '0';
  signal tick_out_3   : std_logic := '0';
  signal ctrl_out_3   : std_logic_vector (1 downto 0) := (others => '0');
  signal time_out_3   : std_logic_vector (5 downto 0) := (others => '0');
  signal rxvalid_3    : std_logic := '0';
  signal rxhalff_3    : std_logic := '0';
  signal rxflag_3     : std_logic := '0';
  signal rxdata_3     : std_logic_vector (7 downto 0) := (others => '0');
  signal rxread_3     : std_logic := '0';
  signal started_3    : std_logic := '0';
  signal connecting_3 : std_logic := '0';
  signal running_3    : std_logic := '0';
  signal errdisc_3    : std_logic := '0';
  signal errpar_3     : std_logic := '0';
  signal erresc_3     : std_logic := '0';
  signal errcred_3    : std_logic := '0';
  signal spw_di_3     : std_logic := '0';
  signal spw_si_3     : std_logic := '0';
  signal spw_do_3     : std_logic := '0';
  signal spw_so_3     : std_logic := '0';
  signal autostart_4  : std_logic := '0';
  signal linkstart_4  : std_logic := '0';
  signal linkdis_4    : std_logic := '0';
  signal txdivcnt_4   : std_logic_vector (7 downto 0) := (others => '0');
  signal tick_in_4    : std_logic := '0';
  signal ctrl_in_4    : std_logic_vector (1 downto 0) := (others => '0');
  signal time_in_4    : std_logic_vector (5 downto 0) := (others => '0');
  signal txwrite_4    : std_logic := '0';
  signal txflag_4     : std_logic := '0';
  signal txdata_4     : std_logic_vector (7 downto 0) := (others => '0');
  signal txrdy_4      : std_logic := '0';
  signal txhalff_4    : std_logic := '0';
  signal tick_out_4   : std_logic := '0';
  signal ctrl_out_4   : std_logic_vector (1 downto 0) := (others => '0');
  signal time_out_4   : std_logic_vector (5 downto 0) := (others => '0');
  signal rxvalid_4    : std_logic := '0';
  signal rxhalff_4    : std_logic := '0';
  signal rxflag_4     : std_logic := '0';
  signal rxdata_4     : std_logic_vector (7 downto 0) := (others => '0');
  signal rxread_4     : std_logic := '0';
  signal started_4    : std_logic := '0';
  signal connecting_4 : std_logic := '0';
  signal running_4    : std_logic := '0';
  signal errdisc_4    : std_logic := '0';
  signal errpar_4     : std_logic := '0';
  signal erresc_4     : std_logic := '0';
  signal errcred_4    : std_logic := '0';
  signal spw_di_4     : std_logic := '0';
  signal spw_si_4     : std_logic := '0';
  signal spw_do_4     : std_logic := '0';
  signal spw_so_4     : std_logic := '0';
  signal autostart_5  : std_logic := '0';
  signal linkstart_5  : std_logic := '0';
  signal linkdis_5    : std_logic := '0';
  signal txdivcnt_5   : std_logic_vector (7 downto 0) := (others => '0');
  signal tick_in_5    : std_logic := '0';
  signal ctrl_in_5    : std_logic_vector (1 downto 0) := (others => '0');
  signal time_in_5    : std_logic_vector (5 downto 0) := (others => '0');
  signal txwrite_5    : std_logic := '0';
  signal txflag_5     : std_logic := '0';
  signal txdata_5     : std_logic_vector (7 downto 0) := (others => '0');
  signal txrdy_5      : std_logic := '0';
  signal txhalff_5    : std_logic := '0';
  signal tick_out_5   : std_logic := '0';
  signal ctrl_out_5   : std_logic_vector (1 downto 0) := (others => '0');
  signal time_out_5   : std_logic_vector (5 downto 0) := (others => '0');
  signal rxvalid_5    : std_logic := '0';
  signal rxhalff_5    : std_logic := '0';
  signal rxflag_5     : std_logic := '0';
  signal rxdata_5     : std_logic_vector (7 downto 0) := (others => '0');
  signal rxread_5     : std_logic := '0';
  signal started_5    : std_logic := '0';
  signal connecting_5 : std_logic := '0';
  signal running_5    : std_logic := '0';
  signal errdisc_5    : std_logic := '0';
  signal errpar_5     : std_logic := '0';
  signal erresc_5     : std_logic := '0';
  signal errcred_5    : std_logic := '0';
  signal spw_di_5     : std_logic := '0';
  signal spw_si_5     : std_logic := '0';
  signal spw_do_5     : std_logic := '0';
  signal spw_so_5     : std_logic := '0';
  -- [[[end]]]


begin  -- architecture behav

  -- [[[cog
  -- tmpl = """
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
  -- """.strip()
  -- for i in range(0, n-1):
  --   print(tmpl.format(i = i))
  -- ]]]
  link0: entity work.spwstream
    generic map (
      sysfreq         => sysfreq,
      txclkfreq       => txclkfreq,
      rximpl          => impl_generic,
      rxchunk         => 1,
      tximpl          => impl_generic,
      rxfifosize_bits => 11,
      txfifosize_bits => 11)
    port map (
      clk        => clk,
      rxclk      => clk,
      txclk      => clk,
      rst        => rst,
      autostart  => autostart_0,
      linkstart  => linkstart_0,
      linkdis    => linkdis_0,
      txdivcnt   => txdivcnt_0,
      tick_in    => tick_in_0,
      ctrl_in    => ctrl_in_0,
      time_in    => time_in_0,
      txwrite    => txwrite_0,
      txflag     => txflag_0,
      txdata     => txdata_0,
      txrdy      => txrdy_0,
      txhalff    => txhalff_0,
      tick_out   => tick_out_0,
      ctrl_out   => ctrl_out_0,
      time_out   => time_out_0,
      rxvalid    => rxvalid_0,
      rxhalff    => rxhalff_0,
      rxflag     => rxflag_0,
      rxdata     => rxdata_0,
      rxread     => rxread_0,
      started    => started_0,
      connecting => connecting_0,
      running    => running_0,
      errdisc    => errdisc_0,
      errpar     => errpar_0,
      erresc     => erresc_0,
      errcred    => errcred_0,
      spw_di     => spw_di_0,
      spw_si     => spw_si_0,
      spw_do     => spw_do_0,
      spw_so     => spw_so_0);
  link1: entity work.spwstream
    generic map (
      sysfreq         => sysfreq,
      txclkfreq       => txclkfreq,
      rximpl          => impl_generic,
      rxchunk         => 1,
      tximpl          => impl_generic,
      rxfifosize_bits => 11,
      txfifosize_bits => 11)
    port map (
      clk        => clk,
      rxclk      => clk,
      txclk      => clk,
      rst        => rst,
      autostart  => autostart_1,
      linkstart  => linkstart_1,
      linkdis    => linkdis_1,
      txdivcnt   => txdivcnt_1,
      tick_in    => tick_in_1,
      ctrl_in    => ctrl_in_1,
      time_in    => time_in_1,
      txwrite    => txwrite_1,
      txflag     => txflag_1,
      txdata     => txdata_1,
      txrdy      => txrdy_1,
      txhalff    => txhalff_1,
      tick_out   => tick_out_1,
      ctrl_out   => ctrl_out_1,
      time_out   => time_out_1,
      rxvalid    => rxvalid_1,
      rxhalff    => rxhalff_1,
      rxflag     => rxflag_1,
      rxdata     => rxdata_1,
      rxread     => rxread_1,
      started    => started_1,
      connecting => connecting_1,
      running    => running_1,
      errdisc    => errdisc_1,
      errpar     => errpar_1,
      erresc     => erresc_1,
      errcred    => errcred_1,
      spw_di     => spw_di_1,
      spw_si     => spw_si_1,
      spw_do     => spw_do_1,
      spw_so     => spw_so_1);
  link2: entity work.spwstream
    generic map (
      sysfreq         => sysfreq,
      txclkfreq       => txclkfreq,
      rximpl          => impl_generic,
      rxchunk         => 1,
      tximpl          => impl_generic,
      rxfifosize_bits => 11,
      txfifosize_bits => 11)
    port map (
      clk        => clk,
      rxclk      => clk,
      txclk      => clk,
      rst        => rst,
      autostart  => autostart_2,
      linkstart  => linkstart_2,
      linkdis    => linkdis_2,
      txdivcnt   => txdivcnt_2,
      tick_in    => tick_in_2,
      ctrl_in    => ctrl_in_2,
      time_in    => time_in_2,
      txwrite    => txwrite_2,
      txflag     => txflag_2,
      txdata     => txdata_2,
      txrdy      => txrdy_2,
      txhalff    => txhalff_2,
      tick_out   => tick_out_2,
      ctrl_out   => ctrl_out_2,
      time_out   => time_out_2,
      rxvalid    => rxvalid_2,
      rxhalff    => rxhalff_2,
      rxflag     => rxflag_2,
      rxdata     => rxdata_2,
      rxread     => rxread_2,
      started    => started_2,
      connecting => connecting_2,
      running    => running_2,
      errdisc    => errdisc_2,
      errpar     => errpar_2,
      erresc     => erresc_2,
      errcred    => errcred_2,
      spw_di     => spw_di_2,
      spw_si     => spw_si_2,
      spw_do     => spw_do_2,
      spw_so     => spw_so_2);
  link3: entity work.spwstream
    generic map (
      sysfreq         => sysfreq,
      txclkfreq       => txclkfreq,
      rximpl          => impl_generic,
      rxchunk         => 1,
      tximpl          => impl_generic,
      rxfifosize_bits => 11,
      txfifosize_bits => 11)
    port map (
      clk        => clk,
      rxclk      => clk,
      txclk      => clk,
      rst        => rst,
      autostart  => autostart_3,
      linkstart  => linkstart_3,
      linkdis    => linkdis_3,
      txdivcnt   => txdivcnt_3,
      tick_in    => tick_in_3,
      ctrl_in    => ctrl_in_3,
      time_in    => time_in_3,
      txwrite    => txwrite_3,
      txflag     => txflag_3,
      txdata     => txdata_3,
      txrdy      => txrdy_3,
      txhalff    => txhalff_3,
      tick_out   => tick_out_3,
      ctrl_out   => ctrl_out_3,
      time_out   => time_out_3,
      rxvalid    => rxvalid_3,
      rxhalff    => rxhalff_3,
      rxflag     => rxflag_3,
      rxdata     => rxdata_3,
      rxread     => rxread_3,
      started    => started_3,
      connecting => connecting_3,
      running    => running_3,
      errdisc    => errdisc_3,
      errpar     => errpar_3,
      erresc     => erresc_3,
      errcred    => errcred_3,
      spw_di     => spw_di_3,
      spw_si     => spw_si_3,
      spw_do     => spw_do_3,
      spw_so     => spw_so_3);
  link4: entity work.spwstream
    generic map (
      sysfreq         => sysfreq,
      txclkfreq       => txclkfreq,
      rximpl          => impl_generic,
      rxchunk         => 1,
      tximpl          => impl_generic,
      rxfifosize_bits => 11,
      txfifosize_bits => 11)
    port map (
      clk        => clk,
      rxclk      => clk,
      txclk      => clk,
      rst        => rst,
      autostart  => autostart_4,
      linkstart  => linkstart_4,
      linkdis    => linkdis_4,
      txdivcnt   => txdivcnt_4,
      tick_in    => tick_in_4,
      ctrl_in    => ctrl_in_4,
      time_in    => time_in_4,
      txwrite    => txwrite_4,
      txflag     => txflag_4,
      txdata     => txdata_4,
      txrdy      => txrdy_4,
      txhalff    => txhalff_4,
      tick_out   => tick_out_4,
      ctrl_out   => ctrl_out_4,
      time_out   => time_out_4,
      rxvalid    => rxvalid_4,
      rxhalff    => rxhalff_4,
      rxflag     => rxflag_4,
      rxdata     => rxdata_4,
      rxread     => rxread_4,
      started    => started_4,
      connecting => connecting_4,
      running    => running_4,
      errdisc    => errdisc_4,
      errpar     => errpar_4,
      erresc     => erresc_4,
      errcred    => errcred_4,
      spw_di     => spw_di_4,
      spw_si     => spw_si_4,
      spw_do     => spw_do_4,
      spw_so     => spw_so_4);
  link5: entity work.spwstream
    generic map (
      sysfreq         => sysfreq,
      txclkfreq       => txclkfreq,
      rximpl          => impl_generic,
      rxchunk         => 1,
      tximpl          => impl_generic,
      rxfifosize_bits => 11,
      txfifosize_bits => 11)
    port map (
      clk        => clk,
      rxclk      => clk,
      txclk      => clk,
      rst        => rst,
      autostart  => autostart_5,
      linkstart  => linkstart_5,
      linkdis    => linkdis_5,
      txdivcnt   => txdivcnt_5,
      tick_in    => tick_in_5,
      ctrl_in    => ctrl_in_5,
      time_in    => time_in_5,
      txwrite    => txwrite_5,
      txflag     => txflag_5,
      txdata     => txdata_5,
      txrdy      => txrdy_5,
      txhalff    => txhalff_5,
      tick_out   => tick_out_5,
      ctrl_out   => ctrl_out_5,
      time_out   => time_out_5,
      rxvalid    => rxvalid_5,
      rxhalff    => rxhalff_5,
      rxflag     => rxflag_5,
      rxdata     => rxdata_5,
      rxread     => rxread_5,
      started    => started_5,
      connecting => connecting_5,
      running    => running_5,
      errdisc    => errdisc_5,
      errpar     => errpar_5,
      erresc     => erresc_5,
      errcred    => errcred_5,
      spw_di     => spw_di_5,
      spw_si     => spw_si_5,
      spw_do     => spw_do_5,
      spw_so     => spw_so_5);
  -- [[[end]]]

  router0: entity work.SpaceWireRouterIP
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

  generate_clock: process is
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

  sim: process is
    procedure ensure (
      signal s   : in std_logic;
      constant v : in std_logic) is
    begin  -- procedure ensure
      if s /= v then
        wait until s = v;
      end if;
    end procedure ensure;
    type byte9 is array (natural range <>) of std_logic_vector (8 downto 0);
    constant pkts : byte9 (0 to 2) := (
      "0" & x"02",
      "0" & x"ab",
      "1" & x"00");
    variable rnd : RandomPType;
    variable packets : integer_array_t;
    variable d : std_logic_vector (31 downto 0);
    variable n : integer;
    variable crc : crc_t;

    type rmap_hdr_t is protected
      procedure init;
      procedure append (d : std_logic_vector (7 downto 0));
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
        append(r, to_integer(unsigned(crc.get)));
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

    variable rmap_hdr : rmap_hdr_t;

  begin  -- process sim
    test_runner_setup(runner, runner_cfg);
    rnd.InitSeed(rnd'instance_name);
    packets := new_1d(0, 9, false);
    while test_suite loop
      if run("Link up test") then
        autostart_0 <= '1';
        autostart_1 <= '1';
        autostart_2 <= '1';
        autostart_3 <= '1';
        autostart_4 <= '1';
        autostart_5 <= '1';
        rst <= '1';
        wait for 20*T;
        rst <= '0';
        wait for 100 us;
        check_equal(running_0, '1', result("Link[0] running"));
        check_equal(running_1, '1', result("Link[1] running"));
        check_equal(running_2, '1', result("Link[2] running"));
        check_equal(running_3, '1', result("Link[3] running"));
        check_equal(running_4, '1', result("Link[4] running"));
        check_equal(running_5, '1', result("Link[5] running"));
      elsif run("Simple transfer") then
        autostart_0 <= '1';
        autostart_1 <= '1';
        autostart_2 <= '1';
        autostart_3 <= '1';
        autostart_4 <= '1';
        autostart_5 <= '1';
        rst <= '1';
        wait for 20*T;
        rst <= '0';
        ensure(running_0, '1');
        ensure(running_1, '1');

        append(packets, 16#002#);       -- destination address
        for i in 0 to 63 loop
          append(packets, rnd.RandInt(0, 255));
        end loop;  -- i
        append(packets, 16#100#);

        ensure(txrdy_0, '1');
        for i in 0 to length(packets)-1 loop
          d := std_logic_vector(to_unsigned(get(packets, i), 32));
          wait until falling_edge(clk);
          txdata_0  <= d(7 downto 0);
          txflag_0  <= d(8);
          txwrite_0 <= '1';
          wait until rising_edge(clk);
        end loop;  -- i
        wait until falling_edge(clk);
        txwrite_0 <= '0';

        wait until falling_edge(clk);
        rxread_1 <= '1';
        n := 0;
        while true loop
          wait until rising_edge(clk);
          if rxvalid_1 = '1' then
            n := n + 1;
            d := std_logic_vector(to_unsigned(get(packets, n), 32));
            if rxflag_1 = '1' then
              check_equal(rxdata_1, std_logic_vector'(x"00"));  -- EOP
              exit;
            else
              check_equal(rxdata_1, d(7 downto 0));
            end if;
          end if;
        end loop;
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
        rmap_hdr.init;
        rmap_hdr.append(x"fe");         -- target logical address
        rmap_hdr.append(x"01");         -- protocol ID (RMAP)
        rmap_hdr.append(
          "01" &                        -- packet type (COMMAND)
          "0" &                         -- write/read (READ)
          "0" &                         -- verify (NO VERIFY)
          "1" &                         -- reply (DO REPLY)
          "1" &                         -- single/incrementing address (INCREMENT)
          "00"                          -- reply address length (0)
          );
        rmap_hdr.append(x"02");         -- RMAP key
        rmap_hdr.append(x"fe");         -- Initiator logical address (default)
        rmap_hdr.append(x"00");         -- TX ID MSB
        rmap_hdr.append(x"05");         -- TX ID LSB
        rmap_hdr.append(x"00");         -- Extended address
        rmap_hdr.append(x"00");         -- Address MSB
        rmap_hdr.append(x"00");
        rmap_hdr.append(x"08");
        rmap_hdr.append(x"00");         -- Address LSB
        rmap_hdr.append(x"00");         -- Data length MSB
        rmap_hdr.append(x"00");
        rmap_hdr.append(x"04");         -- Data length LSB
        rmap_hdr.finalize;

        for i in 0 to rmap_hdr.length - 1 loop
          log(hex_image(rmap_hdr.get(i)));
        end loop;  -- i

        append(packets, 16#000#);       -- destination address
        for i in 0 to rmap_hdr.length - 1 loop
          append(packets, to_integer(unsigned(rmap_hdr.get(i))));
        end loop;  -- i
        append(packets, 16#100#);       -- EOP

        autostart_0 <= '1';
        rst <= '1';
        wait for 20 * T;

        rst <= '0';
        wait for 20 * T;

        ensure(txrdy_0, '1');
        for i in 0 to length(packets)-1 loop
          d := std_logic_vector(to_unsigned(get(packets, i), 32));
          wait until falling_edge(clk);
          txdata_0  <= d(7 downto 0);
          txflag_0  <= d(8);
          txwrite_0 <= '1';
          wait until rising_edge(clk);
        end loop;  -- i
        wait until falling_edge(clk);
        txwrite_0 <= '0';
        wait for 10 us;

        wait until falling_edge(clk);
        rxread_0 <= '1';
        n := 0;
        while true loop
          wait until rising_edge(clk);
          if rxvalid_0 = '1' then
            if rxflag_0 = '1' then
              check_equal(rxdata_0, std_logic_vector'(x"00"));  -- EOP
              exit;
            else
              case n is
                when 0 =>
                  crc.init;
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"fe"), "Initiator logical address");
                when 1 =>
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"01"), "Protocol ID");
                when 2 =>
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'("00" & "0011" & "00"), "Instruction");
                when 3 =>
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"00"), "Status");
                when 4 =>
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"fe"), "Target logical address");
                when 5 =>
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"00"), "TX ID (MSB)");
                when 6 =>
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"05"), "TX ID (LSB)");
                when 7 =>
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"00"), "Reserved");
                when 8 =>
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"00"), "Data length (MSB)");
                when 9 =>
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"00"), "Data length");
                when 10 =>
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"04"), "Data length (LSB)");
                when 11 =>
                  crc.finalize;
                  check_equal(rxdata_0, crc.get, "Header CRC");
                when 12 =>
                  crc.init;
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"40"), "IDCODE[3]");
                when 13 =>
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"22"), "IDCODE[2]");
                when 14 =>
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"49"), "IDCODE[1]");
                when 15 =>
                  crc.update(rxdata_0);
                  check_equal(rxdata_0, std_logic_vector'(x"50"), "IDCODE[0]");
                when 16 =>
                  crc.finalize;
                  check_equal(rxdata_0, crc.get, "Data CRC");
                when others => null;
              end case;
            end if;
            n := n + 1;
          end if;
        end loop;
      end if;
    end loop;

    test_runner_cleanup(runner);
    wait;
  end process sim;

  test_runner_watchdog(runner, 10 ms);
end architecture behav;

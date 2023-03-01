library ieee;
use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

library OSVVM;
use OSVVM.TbUtilPkg.all;

use work.spwpkg.all;
use work.spw_actor_pkg.all;

entity spw_actor is
  generic (
    name : string;
    sysfreq    : real := 100.0e6;
    txclkfreq  : real := 100.0e6);
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    spw_di : in  std_logic;
    spw_si : in  std_logic;
    spw_do : out std_logic;
    spw_so : out std_logic
    );
end entity;


architecture behav of spw_actor is
  constant self : actor_t   := vunit_lib.com_pkg.new_actor(name);
  signal done   : std_logic := '0';

  signal autostart  : std_logic;
  signal linkstart  : std_logic;
  signal linkdis    : std_logic;
  signal txdivcnt   : std_logic_vector(7 downto 0);
  signal tick_in    : std_logic;
  signal ctrl_in    : std_logic_vector(1 downto 0);
  signal time_in    : std_logic_vector(5 downto 0);
  signal txwrite    : std_logic;
  signal txflag     : std_logic;
  signal txdata     : std_logic_vector(7 downto 0);
  signal txrdy      : std_logic;
  signal txhalff    : std_logic;
  signal tick_out   : std_logic;
  signal ctrl_out   : std_logic_vector(1 downto 0);
  signal time_out   : std_logic_vector(5 downto 0);
  signal rxvalid    : std_logic;
  signal rxhalff    : std_logic;
  signal rxflag     : std_logic;
  signal rxdata     : std_logic_vector(7 downto 0);
  signal rxread     : std_logic;
  signal started    : std_logic;
  signal connecting : std_logic;
  signal running    : std_logic;
  signal errdisc    : std_logic;
  signal errpar     : std_logic;
  signal erresc     : std_logic;
  signal errcred    : std_logic;

begin  -- architecture behav

  message_handler : process is
    variable request_msg : msg_t;
    variable reply_msg : msg_t;
    variable msg_type    : msg_type_t;
    variable payload     : integer;
    variable linkctrl : std_logic_vector (2 downto 0);
  begin
    autostart <= '0';
    linkstart <= '0';
    linkdis   <= '0';
    txdivcnt  <= x"00";
    tick_in   <= '0';
    ctrl_in   <= "00";
    time_in   <= "000000";
    txwrite   <= '0'; txflag <= '0'; txdata <= x"00";
    while true loop
      receive(net, self, request_msg);
      msg_type := message_type(request_msg);
      FindRisingEdge(clk);
      if msg_type = spw_type_linkctl then
        linkctrl := pop(request_msg);
        autostart <= linkctrl(2);
        linkstart <= linkctrl(1);
        linkdis   <= linkctrl(0);
      elsif msg_type = spw_type_linkstatus then
        reply_msg := new_msg(spw_type_linkstatus_reply);
        push(reply_msg, started & connecting & running);
        reply(net, request_msg, reply_msg);
      elsif msg_type = spw_type_pollrunning then
        reply_msg := new_msg(spw_type_pollrunning_reply);
        if running /= '1' then
          wait until running = '1';
        end if;
        reply(net, request_msg, reply_msg);
      elsif msg_type = spw_type_txdata then
        while not is_empty(request_msg) loop
          if txrdy /= '1' then wait until txrdy = '1'; end if;
          txdata <= pop(request_msg); txflag <= '0'; txwrite <= '1';
          wait until rising_edge(clk);
        end loop;
        if txrdy /= '1' then wait until txrdy = '1'; end if;
        txdata <= x"00"; txflag <= '1'; txwrite <= '1';
        wait until rising_edge(clk);
        txwrite <= '0';
      elsif msg_type = spw_type_delay then
        wait for pop(request_msg);
      else
        unexpected_msg_type(msg_type);
      end if;
    end loop;
    wait;
  end process;

  publisher: process is
    variable rxpacket : msg_t;
    variable packet_start : boolean := true;
  begin
    while true loop
      wait until rising_edge(clk);
      rxread <= '1';
      if rxvalid = '1' then
        if packet_start then
          rxpacket := new_msg;
          packet_start := false;
        end if;
        if rxflag = '0' then
          push(rxpacket, rxdata);
        else
          publish(net, self, rxpacket);
          delete(rxpacket);
          packet_start := true;
        end if;
      end if;
    end loop;
    wait;
  end process;


  link0 : entity work.spwstream
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
      autostart  => autostart,
      linkstart  => linkstart,
      linkdis    => linkdis,
      txdivcnt   => txdivcnt,
      tick_in    => tick_in,
      ctrl_in    => ctrl_in,
      time_in    => time_in,
      txwrite    => txwrite,
      txflag     => txflag,
      txdata     => txdata,
      txrdy      => txrdy,
      txhalff    => txhalff,
      tick_out   => tick_out,
      ctrl_out   => ctrl_out,
      time_out   => time_out,
      rxvalid    => rxvalid,
      rxhalff    => rxhalff,
      rxflag     => rxflag,
      rxdata     => rxdata,
      rxread     => rxread,
      started    => started,
      connecting => connecting,
      running    => running,
      errdisc    => errdisc,
      errpar     => errpar,
      erresc     => erresc,
      errcred    => errcred,
      spw_di     => spw_di,
      spw_si     => spw_si,
      spw_do     => spw_do,
      spw_so     => spw_so);
end architecture behav;

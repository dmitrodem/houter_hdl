library ieee;
context ieee.ieee_std_context;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

library OSVVM;
use OSVVM.TbUtilPkg.all;

use work.spwpkg.all;
use work.spw_actor_pkg.all;

entity tb_spw_actor is
  generic (
    runner_cfg : string);
end entity tb_spw_actor;

architecture behav of tb_spw_actor is
  constant freq : real := 100.0e6;

  signal clk    : std_logic;
  signal rst    : std_logic;
  signal spw_di : std_logic;
  signal spw_si : std_logic;
  signal spw_do : std_logic;
  signal spw_so : std_logic;
begin  -- architecture behav

  actor0 : entity work.spw_actor
    generic map (
      name      => "e0",
      sysfreq   => freq,
      txclkfreq => freq)
    port map (
      clk    => clk,
      rst    => rst,
      spw_di => spw_di,
      spw_si => spw_si,
      spw_do => spw_do,
      spw_so => spw_so);

  actor1 : entity work.spw_actor
    generic map (
      name      => "e1",
      sysfreq   => freq,
      txclkfreq => freq)
    port map (
      clk    => clk,
      rst    => rst,
      spw_di => spw_do,
      spw_si => spw_so,
      spw_do => spw_di,
      spw_so => spw_si);

  process is
  begin  -- process
    CreateClock(clk, (1000 ms)/freq);
    wait;
  end process;

  process is
  begin  -- process
    CreateReset(rst, '1', clk, 10*(1000 ms)/freq);
    wait;
  end process;

  process is
    variable e0              : actor_t := find("e0");
    variable e1              : actor_t := find("e1");
    variable linkctrl        : std_logic_vector (2 downto 0);
    variable msg, msg1, msg2 : msg_t;
    variable msg1r, msg2r    : msg_t;
    variable d               : std_logic_vector (31 downto 0);
  begin  -- process
    test_runner_setup(runner, runner_cfg);
    while test_suite loop
      wait until rst = '0';
      if run("Link up") then
        show(com_logger, display_handler, trace);

        wait for 1 us;
        linkctrl := "110";
        msg      := new_msg(spw_type_linkctl);
        push(msg, linkctrl);
        msg1     := copy(msg);
        msg2     := copy(msg);
        delete(msg);
        send(net, e0, msg1);
        send(net, e1, msg2);
        wait for 100 us;

        msg  := new_msg(spw_type_linkstatus);
        msg1 := copy(msg);
        msg2 := copy(msg);
        delete(msg);
        send(net, e0, msg1);
        send(net, e1, msg2);
        receive_reply(net, msg1, msg1r);
        receive_reply(net, msg2, msg2r);

        d(2 downto 0) := pop(msg1r);
        d(5 downto 3) := pop(msg2r);

        log(hex_image(d));

        msg := new_msg(spw_type_txdata);
        push(msg, std_logic_vector'(x"00"));
        push(msg, std_logic_vector'(x"ab"));
        push(msg, std_logic_vector'(x"cd"));
        send(net, e0, msg);

        wait for 10 us;

      end if;
    end loop;
    test_runner_cleanup(runner);
  end process;

  process is
    variable self : actor_t := new_actor("subscriber");
    variable e1   : actor_t := find("e1");
    variable msg : msg_t;
    variable i : integer;
  begin
    subscribe(self, e1);
    loop
      receive(net, self, msg);
      i := 0;
      while not is_empty(msg) loop
        log(to_string(i) & " :: " & hex_image(pop(msg)));
        i := i + 1;
      end loop;
    end loop;
    wait;
  end process;

end architecture behav;

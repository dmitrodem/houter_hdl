library ieee;
use ieee.std_logic_1164.all;

library vunit_lib;
context vunit_lib.vunit_context;

package rmap_crc is
  type crc_t is protected
    procedure init;
    procedure update(d : std_logic_vector (7 downto 0));
    procedure finalize;
    impure function get return std_logic_vector;
  end protected;

  procedure crc_test;
end package rmap_crc;

package body rmap_crc is

  type crc_t is protected body

    variable r : std_logic_vector (7 downto 0);

    procedure init is
    begin  -- procedure init
      r := std_logic_vector'(x"00");
    end procedure init;

    procedure update (d : std_logic_vector (7 downto 0)) is
      variable v, vn : std_logic_vector (7 downto 0);
      variable b : std_logic;
    begin  -- procedure update
      v := r;
      for i in 0 to 7 loop
        b := v(7) xor d(i);
        vn(0) := b;
        vn(1) := v(0) xor b;
        vn(2) := v(1) xor b;
        vn(3) := v(2);
        vn(4) := v(3);
        vn(5) := v(4);
        vn(6) := v(5);
        vn(7) := v(6);
        v := vn;
      end loop;  -- i
      r := v;
    end procedure update;

    procedure finalize is
      variable v : std_logic_vector (7 downto 0);
    begin
      for i in 0 to 7 loop
        v(7-i) := r(i);
      end loop;  -- i
      r := v;
    end procedure finalize;

    impure function get return std_logic_vector is
    begin
      return r;
    end function get;
  end protected body;

  procedure crc_test is
    variable crc : crc_t;
  begin  -- procedure crc_test
    crc.init;
    crc.update(x"01"); crc.update(x"02"); crc.update(x"03"); crc.update(x"04");
    crc.update(x"05"); crc.update(x"06"); crc.update(x"07"); crc.update(x"08");
    crc.finalize;
    check_equal(crc.get, std_logic_vector'(x"b0"));

    crc.init;
    crc.update(x"53"); crc.update(x"70"); crc.update(x"61"); crc.update(x"63");
    crc.update(x"65"); crc.update(x"57"); crc.update(x"69"); crc.update(x"72");
    crc.update(x"65"); crc.update(x"20"); crc.update(x"69"); crc.update(x"73");
    crc.update(x"20"); crc.update(x"62"); crc.update(x"65"); crc.update(x"61");
    crc.update(x"75"); crc.update(x"74"); crc.update(x"69"); crc.update(x"66");
    crc.update(x"75"); crc.update(x"6c"); crc.update(x"21"); crc.update(x"21");
    crc.finalize;
    check_equal(crc.get, std_logic_vector'(x"84"));

    crc.init;
    crc.update(x"10"); crc.update(x"56"); crc.update(x"c3"); crc.update(x"95");
    crc.update(x"a5"); crc.update(x"75"); crc.update(x"38"); crc.update(x"63");
    crc.update(x"2f"); crc.update(x"86"); crc.update(x"7b"); crc.update(x"01");
    crc.update(x"32"); crc.update(x"de"); crc.update(x"35"); crc.update(x"7a");
    crc.finalize;
    check_equal(crc.get, std_logic_vector'(x"18"));

  end procedure crc_test;

end package body rmap_crc;

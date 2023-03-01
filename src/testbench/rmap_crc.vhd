library ieee;
context ieee.ieee_std_context;
library vunit_lib;
context vunit_lib.vunit_context;

package rmap_crc is
  type crc_t is protected
    procedure init;
    procedure update(d : std_logic_vector (7 downto 0));
    procedure update(d : integer range 0 to 255);
    procedure finalize;
    impure function get return std_logic_vector;
    impure function get return integer;
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

    procedure update(d : integer range 0 to 255) is
    begin
      update(std_logic_vector(to_unsigned(d, 8)));
    end procedure;

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

    impure function get return integer is
    begin
      return to_integer(unsigned(r));
    end function get;

  end protected body;

  procedure crc_test is
    variable crc : crc_t;
    variable r : integer range 0 to 255;
  begin  -- procedure crc_test
    crc.init;
    crc.update(16#01#); crc.update(16#02#); crc.update(16#03#); crc.update(16#04#);
    crc.update(16#05#); crc.update(16#06#); crc.update(16#07#); crc.update(16#08#);
    crc.finalize;
    r := crc.get;
    vunit_lib.check_pkg.check_equal(16#b0#, r);

    crc.init;
    crc.update(16#53#); crc.update(16#70#); crc.update(16#61#); crc.update(16#63#);
    crc.update(16#65#); crc.update(16#57#); crc.update(16#69#); crc.update(16#72#);
    crc.update(16#65#); crc.update(16#20#); crc.update(16#69#); crc.update(16#73#);
    crc.update(16#20#); crc.update(16#62#); crc.update(16#65#); crc.update(16#61#);
    crc.update(16#75#); crc.update(16#74#); crc.update(16#69#); crc.update(16#66#);
    crc.update(16#75#); crc.update(16#6c#); crc.update(16#21#); crc.update(16#21#);
    crc.finalize;
    r := crc.get;
    vunit_lib.check_pkg.check_equal(16#84#, r);

    crc.init;
    crc.update(16#10#); crc.update(16#56#); crc.update(16#c3#); crc.update(16#95#);
    crc.update(16#a5#); crc.update(16#75#); crc.update(16#38#); crc.update(16#63#);
    crc.update(16#2f#); crc.update(16#86#); crc.update(16#7b#); crc.update(16#01#);
    crc.update(16#32#); crc.update(16#de#); crc.update(16#35#); crc.update(16#7a#);
    crc.finalize;
    r := crc.get;
    vunit_lib.check_pkg.check_equal(16#18#, r);

  end procedure crc_test;

end package body rmap_crc;

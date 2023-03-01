library ieee;
context ieee.ieee_std_context;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;
use vunit_lib.integer_array_pkg.all;

use work.rmap_crc.all;

package rmap_pkg is

  constant RMAP_PROTOCOL_ID : integer := 16#01#;
  constant RMAP_DEFAULT_LOGICAL_ADDRESS : integer := 16#FE#;

  type txid_t is protected
    impure function get return integer;
  end protected;

  impure function rmap_request_header (
    target_spw_address        : integer_array_t;
    target_logical_address    : integer;
    protocol_identifier       : integer;
    instruction               : integer;
    key                       : integer;
    reply_address             : integer_array_t;
    initiator_logical_address : integer;
    transaction_identifier    : integer;
    extended_address          : integer;
    address                   : integer;
    data_length               : integer)
    return msg_t;

end package rmap_pkg;

package body rmap_pkg is

  type txid_t is protected body
    variable r : integer := 0;
    impure function get return integer is
      variable result : integer;
    begin
      result := r;
      r := r + 1;
      return result;
    end;
  end protected body;


  impure function rmap_request_header (
    target_spw_address        : integer_array_t;
    target_logical_address    : integer;
    protocol_identifier       : integer;
    instruction               : integer;
    key                       : integer;
    reply_address             : integer_array_t;
    initiator_logical_address : integer;
    transaction_identifier    : integer;
    extended_address          : integer;
    address                   : integer;
    data_length               : integer)
    return msg_t is
    variable msg : msg_t := new_msg;
    variable crc : crc_t;
    variable d : std_logic_vector (7 downto 0);
    variable d16 : std_logic_vector (15 downto 0);
    variable d24 : std_logic_vector (23 downto 0);
    variable d32 : std_logic_vector (31 downto 0);
    alias pushb is push [msg_t, std_ulogic_vector];
  begin
    if not is_null(target_spw_address) then
      for i in 0 to length(target_spw_address)-1 loop
        d := std_logic_vector(to_unsigned(get(target_spw_address, i), 8));
        push(msg, d);
      end loop;  -- i
    end if;
    crc.init;
    d := std_logic_vector(to_unsigned(target_logical_address, 8));
    crc.update(d); push(msg, d);
    d := std_logic_vector(to_unsigned(protocol_identifier, 8));
    crc.update(d); push(msg, d);
    d := std_logic_vector(to_unsigned(instruction, 8));
    crc.update(d); push(msg, d);
    d := std_logic_vector(to_unsigned(key, 8));
    crc.update(d); push(msg, d);
    if not is_null(reply_address) then
      for i in 0 to length(reply_address)-1 loop
        d := std_logic_vector(to_unsigned(get(reply_address, i), 8));
        crc.update(d); push(msg, d);
      end loop;  -- i
    end if;
    d16 := std_logic_vector(to_unsigned(transaction_identifier, 16));
    crc.update(d16(15 downto 8)); push(msg, d16(15 downto 8));
    crc.update(d16(7 downto 0));  push(msg, d16(7 downto 0));
    d := std_logic_vector(to_unsigned(extended_address, 8));
    crc.update(d); push(msg, d);
    d32 := std_logic_vector(to_unsigned(address, 32));
    d := d32 (31 downto 24); crc.update(d); push(msg, d);
    d := d32 (23 downto 16); crc.update(d); push(msg, d);
    d := d32 (15 downto 8) ; crc.update(d); push(msg, d);
    d := d32 (7  downto 0) ; crc.update(d); push(msg, d);
    d24 := std_logic_vector(to_unsigned(data_length, 24));
    d := d24 (23 downto 16); crc.update(d); push(msg, d);
    d := d24 (15 downto 8) ; crc.update(d); push(msg, d);
    d := d24 (7  downto 0) ; crc.update(d); push(msg, d);

    crc.finalize;
    pushb(msg, crc.get);

    return msg;
  end function;


end package body rmap_pkg;

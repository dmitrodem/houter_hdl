library ieee;
context ieee.ieee_std_context;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

package spw_actor_pkg is
  constant spw_type_linkctl           : msg_type_t := new_msg_type("spw_linkctl");
  constant spw_type_linkstatus        : msg_type_t := new_msg_type("spw_linkstatus");
  constant spw_type_linkstatus_reply  : msg_type_t := new_msg_type("spw_linkstatus_reply");
  constant spw_type_pollrunning       : msg_type_t := new_msg_type("spw_pollrunning");
  constant spw_type_pollrunning_reply : msg_type_t := new_msg_type("spw_pollrunning_reply");
  constant spw_type_txdata            : msg_type_t := new_msg_type("spw_txdata");
  constant spw_type_finish            : msg_type_t := new_msg_type("spw_finish");
  constant spw_type_delay             : msg_type_t := new_msg_type("spw_delay");
end package spw_actor_pkg;

package body spw_actor_pkg is

end package body spw_actor_pkg;

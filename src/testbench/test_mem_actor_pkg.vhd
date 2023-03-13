library ieee;
context ieee.ieee_std_context;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

package test_mem_actor_pkg is
    constant test_mem_read  : msg_type_t := new_msg_type("test_mem_read");
    constant test_mem_write : msg_type_t := new_msg_type("test_mem_write");
        
end package test_mem_actor_pkg;

package body test_mem_actor_pkg is
    
end package body test_mem_actor_pkg;

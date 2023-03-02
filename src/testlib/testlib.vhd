library ieee;
use ieee.std_logic_1164.all;

package testlib is
    constant N_MODULES : integer := 32;

    type memdbg_in_t is record
        a   : std_logic_vector(6 downto 0);
        d   : std_logic_vector(7 downto 0);
        cen : std_logic;
        wen : std_logic;
        sel : std_logic_vector (N_MODULES-1 downto 0);
    end record;
    
    type memdbg_out_t is record
        q : std_logic_vector (7 downto 0);
    end record;

end package testlib;

package body testlib is

end package body testlib;


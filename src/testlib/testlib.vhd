library ieee;
use ieee.std_logic_1164.all;

package testlib is
    constant N_MODULES : integer := 24;

    type memdbg_in_t is record
        a   : std_logic_vector(6 downto 0);
        d   : std_logic_vector(7 downto 0);
        cen : std_logic_vector(N_MODULES - 1 downto 0);
        wen : std_logic_vector(N_MODULES - 1 downto 0);
    end record;
    
    constant memdbg_in_none : memdbg_in_t := (
        a   => (others => '0'),
        d   => (others => '0'),
        cen => (others => '1'),
        wen => (others => '1')
    );

    type memdbg_data_vector is array (0 to N_MODULES - 1) of std_logic_vector(7 downto 0);

    type memdbg_out_t is record
        q : memdbg_data_vector;
    end record;

    constant memdbg_out_none : memdbg_out_t := (
        q => (others => (others => '0'))
    );
end package testlib;

package body testlib is

end package body testlib;


library ieee;
use ieee.std_logic_1164.all;

package ftlib is
    function mvote(a, b, c : std_logic) return std_logic;
    function mvote(a, b, c : std_logic_vector) return std_logic_vector;
end package ftlib;

package body ftlib is
    function mvote(a, b, c : std_logic) return std_logic is
        variable v : std_logic_vector(2 downto 0);
    begin
        v := a & b & c;
        case v is
            when "000" => return '0';
            when "001" => return '0';
            when "010" => return '0';
            when "011" => return '1';
            when "100" => return '0';
            when "101" => return '1';
            when "110" => return '1';
            when "111" => return '1';
            when others => return '0'; 
        end case;
        return '0';
    end function;

    function mvote(a, b, c : std_logic_vector)
    return std_logic_vector is
        variable result : std_logic_vector (a'length-1 downto 0);
    begin
        assert a'length = b'length report "len(a) /= len(b)" severity failure;
        assert b'length = c'length report "len(b) /= len(c)" severity failure;        
        for i in 0 to a'length-1 loop
            result(i) := mvote(a(a'low + i), b(b'low + i), c(c'low + i));
        end loop;
        return result;
    end function;
end package body ftlib;

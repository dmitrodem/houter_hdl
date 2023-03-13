library ieee;
context ieee.ieee_std_context;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.com_context;

use work.test_mem_actor_pkg.all;

entity test_mem_actor is
    generic(
        name : string
    );
    port(
        clk               : in  std_logic;
        test_mem_address  : out std_logic_vector(31 downto 0);
        test_mem_data_in  : out std_logic_vector(7 downto 0);
        test_mem_cen      : out std_logic;
        test_mem_wen      : out std_logic;
        test_mem_data_out : in  std_logic_vector(7 downto 0)
    );
end entity test_mem_actor;

architecture behav of test_mem_actor is
    constant self : actor_t := new_actor(name);

begin

    do_job : process is
        variable rcv_msg      : msg_t;
        variable rcv_msg_type : msg_type_t;
        variable reply_msg    : msg_t;
        variable vaddress     : unsigned(test_mem_address'range);
        variable vdata        : unsigned(test_mem_data_in'range);
        variable n            : integer;
    begin
        test_mem_address <= (others => '0');
        test_mem_data_in <= (others => '0');
        test_mem_cen     <= '1';
        test_mem_wen     <= '1';
        loop
            wait until rising_edge(clk);
            receive(net, self, rcv_msg);
            rcv_msg_type := message_type(rcv_msg);
            if rcv_msg_type = test_mem_read then
                reply_msg := new_msg;
                vaddress  := to_unsigned(pop_integer(rcv_msg), vaddress'length);
                if is_empty(rcv_msg) then
                    n := 1;
                else
                    n := pop(rcv_msg);
                end if;
                for i in 0 to n loop
                    test_mem_address <= std_logic_vector(vaddress);
                    test_mem_cen <= '0';
                    test_mem_wen <= '1';
                    vaddress := vaddress + 1;
                    wait until rising_edge(clk);
                    if (i /= 0) then 
                        push(reply_msg, to_integer(unsigned(test_mem_data_out)));
                    end if;
                end loop;
                reply(net, rcv_msg, reply_msg);
                test_mem_cen <= '1';
                test_mem_wen <= '1';
            elsif rcv_msg_type = test_mem_write then
                vaddress     := to_unsigned(pop_integer(rcv_msg), vaddress'length);
                while not is_empty(rcv_msg) loop
                    vdata            := to_unsigned(pop_integer(rcv_msg), vdata'length);
                    test_mem_address <= std_logic_vector(vaddress);
                    test_mem_data_in <= std_logic_vector(vdata);
                    test_mem_cen     <= '0';
                    test_mem_wen     <= '0';
                    vaddress         := vaddress + 1;
                    wait until rising_edge(clk);
                end loop;
                test_mem_cen <= '1';
                test_mem_wen <= '1';
            else
                unexpected_msg_type(rcv_msg_type);
            end if;
        end loop;
        wait;
    end process do_job;

end architecture behav;

----------------------------------------------------------------------------------
-- Engineer: Zach Richard
-- 
-- Create Date: 09/02/2019 02:13:38 PM
-- Design Name: 
-- Module Name: lowlevel_dac_intfc_tb - Behavioral
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity lowlevel_dac_intfc_tb is
end lowlevel_dac_intfc_tb;

architecture Behavioral of lowlevel_dac_intfc_tb is
    constant period : time := 1 sec / 100000000;
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    
    signal data_word_in : std_logic_vector(31 downto 0);
    signal serial_data_out : std_logic;
    signal lrck : std_logic;
    signal bclk : std_logic;
    signal mclk : std_logic;
    signal data_latch : std_logic;
    
    
begin

    -- Generate the main clock (100MHZ emu)
    clk <= not clk after (period/2);
    
    
    test_ll_dac : entity lowlevel_dac_intfc port map (
        rst => reset,
        clk100 => clk,
        data_word => data_word_in,
        sdata => serial_data_out,
        lrck => lrck,
        bclk => bclk,
        mclk => mclk,
        latched_data => data_latch
    );
    
    
    main_tb : process 
    begin
    
        wait for 50ns;
        reset <= '0';
        
        
        wait for 50ns;
        data_word_in <= (others => '0');
        wait for (10 ns * 64 * 32); -- 10ns * 64 is the data rate, times 32 bits of data
--        assert data_latch = '1'
--            report "Expected data_latch after 32 bits at 640ns per data bit!";
            
        wait for 50ns;
        data_word_in <= (others => '1');
--        wait for (10 ns * 64 * 32); -- 10ns * 64 is the data rate, times 32 bits of data
--        assert data_latch = '1'
--            report "Expected data_latch after 32 bits at 640ns per data bit!";
        
        --reset <= '1';
        --wait for 50ns;
        --reset <= '0';
        
        wait until data_latch = '1';
        data_word_in <= x"AAAAAAAA"; -- All alternating 
        wait for (10 ns * 64 * 32); 
        
--        for I in 0 to 2147483647 loop
--            data_word_in <= std_logic_vector(to_unsigned(I, data_word_in'length));
--            wait until data_latch = '1';
--        end loop;
        
        wait;
    end process main_tb;


end Behavioral;

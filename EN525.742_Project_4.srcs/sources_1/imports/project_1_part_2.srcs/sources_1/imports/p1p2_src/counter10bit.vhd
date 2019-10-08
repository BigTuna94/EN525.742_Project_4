----------------------------------------------------------------------------------
-- Engineer: Zach Richard
-- 
-- Create Date: 06/18/2019 08:06:43 PM
-- Design Name: 
-- Module Name: counter10bit - Behavioral
-- Project Name: Lab3
-- Target Devices: Nexys4 DDR
-- 
-- Notes: Generates 10 Clock Driven Bits per instance
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter10bit is Port (
    CLK100MHZ : in STD_LOGIC;
    ENABLE : in STD_LOGIC;
    RESET : in STD_LOGIC;
    MAX_CNT : in unsigned (9 downto 0);
    ROLLOVER : out STD_LOGIC;
    COUNTER_OUT : out unsigned (9 downto 0)
);
end counter10bit;

architecture Behavioral of counter10bit is
    signal clear : std_logic;
    signal counter : unsigned (9 downto 0) := (others => '0');
begin

    gen_counter : process(CLK100MHZ, RESET)
    begin
        if RESET = '1' then 
            counter <= (others => '0');
        elsif rising_edge(CLK100MHZ) then
            if ENABLE = '1' then
                if (clear = '1') then
                    counter <= (others => '0');
                else 
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;
    
    clear <= '1' when (counter = MAX_CNT) else '0';
    COUNTER_OUT <= counter;
    ROLLOVER <= clear;

end Behavioral;

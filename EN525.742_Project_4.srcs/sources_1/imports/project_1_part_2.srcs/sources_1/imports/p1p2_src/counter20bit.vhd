----------------------------------------------------------------------------------
-- Engineer: Zach Richard
-- 
-- Create Date: 07/14/2019 09:01:25 PM
-- Design Name: 
-- Module Name: counter20bit - Behavioral
-- Project Name: Lab5
-- Target Devices: Nexys4 DDR
-- 
-- Notes: Generates 20 Clock Driven Bits per instance
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity counter20bit is Port (
    CLK100MHZ : in STD_LOGIC;
    ENABLE : in STD_LOGIC;
    RESET : in STD_LOGIC;
    MAX_CNT : in unsigned (19 downto 0);
    TAP_CNT : in unsigned (19 downto 0);
    TAP : out STD_LOGIC;
    ROLLOVER : out STD_LOGIC;
    COUNTER_OUT : out unsigned (19 downto 0)
);
end counter20bit;

architecture Behavioral of counter20bit is
    signal clear : std_logic;
    signal counter : unsigned (19 downto 0) := (others => '0');
    signal tap_clear : std_logic;
    signal tap_counter : unsigned (19 downto 0) := (others => '0');
begin

    gen_counter : process(CLK100MHZ, RESET)
    begin
        if RESET = '1' then 
            counter <= (others => '0');
            tap_counter <= (others => '0');
            tap_counter <= (others => '0');
        elsif rising_edge(CLK100MHZ) then
            if ENABLE = '1' then
                if (clear = '1') then
                    counter <= (others => '0');
                else 
                    counter <= counter + 1;
                end if;
                
                if (tap_clear = '1') then
                    tap_counter <= (others => '0');
                else 
                    tap_counter <= tap_counter + 1;
                end if;
            else
                counter <= (others => '0');
                tap_counter <= (others => '0');
            end if;
        end if;
    end process;
    
    clear <= '1' when (counter = MAX_CNT) and RESET = '0' else '0';
    COUNTER_OUT <= counter;
    ROLLOVER <= clear;
    
    tap_clear <= '1' when (tap_counter = TAP_CNT) else '0';
    TAP <= tap_clear;
end Behavioral;

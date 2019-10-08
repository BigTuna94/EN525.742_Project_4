----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/14/2019 06:12:49 PM
-- Design Name: 
-- Module Name: parallel_to_serial - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity parallel_to_serial is Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        en : in STD_LOGIC;
        input_data : in STD_LOGIC_VECTOR (31 downto 0);
        curr_bit_index : out integer;
        output_bit : out STD_LOGIC
    );
end parallel_to_serial;

architecture Behavioral of parallel_to_serial is
    signal bit_index_counter : integer range 0 to 23 := 0;
begin

    serialize : process (clk, reset)
    begin
        if reset = '1' then
            bit_index_counter <= 23;
        elsif rising_edge(clk) then
            if en = '1' then                
                output_bit <= input_data(bit_index_counter);
                if bit_index_counter >= 31 then 
                    bit_index_counter <= 0;
                else
                    bit_index_counter <= bit_index_counter + 1;
                end if; 
            end if;
        end if;
    end process;
    
    curr_bit_index <= bit_index_counter;

end Behavioral;

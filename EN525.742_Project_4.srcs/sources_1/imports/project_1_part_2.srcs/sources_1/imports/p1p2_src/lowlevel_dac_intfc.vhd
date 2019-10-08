----------------------------------------------------------------------------------
-- 
-- Engineer: Zach Richard
-- 
-- Create Date: 09/02/2019 02:13:16 PM
-- Module Name: lowlevel_dac_intfc - Behavioral
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.all;


entity lowlevel_dac_intfc is Port (
        rst 		: in std_logic; -- active high asynchronous reset
        clk100		: in std_logic; -- the clock for all flops in the design
        data_word	: in std_logic_vector(31 downto 0); -- 32 bit input data
        sdata		: out std_logic; -- serial data out to the DAC
        lrck		: out std_logic;  -- a 50% duty cycle signal with a frequency of 48.828125 kHz
        bclk  		: out std_logic; -- the dac clocks sdata on the rising edge of this clock, 1.5625MHz with 50% duty cycle
        mclk		: out std_logic; -- a 12.5MHz clock output with arbitrary phase
    latched_data 	: out std_logic -- 1 clock wide pulse which indicates when the current 
                                    -- value of data_word has been read by this component
                                    -- (and can be safely changed)
    );
end lowlevel_dac_intfc;

architecture Behavioral of lowlevel_dac_intfc is
    constant max_mclk_count : unsigned(1 downto 0) := to_unsigned(3, 2);
    signal mclk_count : unsigned (1 downto 0) := (others => '0');
    --signal mclk_chg : std_logic;
    signal mclk_sig : std_logic := '0';
    
    --constant max_lrck_count : unsigned(19 downto 0) := to_unsigned(4*256, 20); 
    --signal lrck_chg : std_logic;
    signal lrck_sig : std_logic := '0';
    
    constant max_bclk_count : unsigned (5 downto 0) := to_unsigned(31, 6);
    signal bclk_count : unsigned (5 downto 0) := (others => '0');
    --signal bclk_chg : std_logic;
    signal bclk_sig : std_logic := '1';
    
    signal data_bit_out : std_logic;
    signal data_bit_index : integer := 31;
    --signal en_p2s : std_logic := '0';
    
    signal latched_data_sig : std_logic := '0';
    
begin
    
    clk_master : process (clk100, rst)
    begin
        if rst = '1' then
            bclk_sig <= '0';
            mclk_sig <= '0';
            latched_data_sig <= '0';
            data_bit_index <= 31;
        elsif rising_edge(clk100) then
        
            -- Defaults
            latched_data_sig <= '0';
        
            -- mclk 
            mclk_count <= mclk_count + 1;
            if mclk_count = max_mclk_count then
                mclk_sig <= not mclk_sig;
                mclk_count <= (others => '0');
            end if;
            
            -- Bclk and driven signals
            bclk_count <= bclk_count + 1;
            if bclk_count = max_bclk_count then
                bclk_sig <= not bclk_sig; -- toggle the bclock signal
                bclk_count <= (others => '0'); -- reset counter
                if bclk_sig = '1' then -- falling edge of bclk about to occur
                    -- push the next data bit
                    --data_bit_out <= data_word(data_bit_index);
                    -- decrement the index counter
                    data_bit_index <= data_bit_index - 1;
                    -- handle rollover
                    if data_bit_index <= 0 then 
                        data_bit_index <= 31;
                    end if;
                    -- handle lrck 
                    --if data_bit_index = 0 or data_bit_index > 16 then
                    if data_bit_index > 16 or data_bit_index = 0 then
                        lrck_sig <= '1';
                    else 
                        lrck_sig <= '0';
                    end if;
                    -- handle latched pulse
                    if data_bit_index = 0 then
                        latched_data_sig <= '1';
                    end if;
                end if;
            end if;
            
        end if;
    end process clk_master;
    
    data_bit_out <= data_word(data_bit_index);
    
    lrck <= lrck_sig;
    bclk <= bclk_sig;
    mclk <= mclk_sig;
    sdata <= data_bit_out;
    latched_data <= latched_data_sig;

end Behavioral;

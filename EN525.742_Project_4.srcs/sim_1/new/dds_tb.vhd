----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/19/2019 09:23:16 PM
-- Design Name: 
-- Module Name: dds_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
library ieee;
use IEEE.std_logic_textio.all;
use STD.textio.all;

use work.all;

entity dds_tb is
end dds_tb;

architecture Behavioral of dds_tb is

COMPONENT dds_compiler_0
  PORT (
    aclk : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_config_tvalid : IN STD_LOGIC;
    s_axis_config_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_data_tvalid : OUT STD_LOGIC;
    m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

    constant period : time := 1 sec / 100000000;
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal resetn : std_logic;
    
    signal dds_input_data : std_logic_vector(31 downto 0) := (others => '0');
    signal dds_tvalid_out : std_logic;
    signal dds_tdata_out : std_logic_vector(15 downto 0);
    
    signal dac_input : std_logic_vector(31 downto 0);
    signal dac_sdata : std_logic;
    signal dac_lrck : std_logic;
    signal dac_bclk : std_logic;
    signal dac_mclk : std_logic;
    signal dac_latched_data : std_logic;
    
    constant pa_50k : std_logic_vector(26 downto 0) := std_logic_vector(TO_UNSIGNED(67109, 27)); -- pase_accum  = (freq_desiredHz * 2^27) / DDS freq = (50000 * 2^27)/100MHz = 67108.864 ~= 67109
    constant pa_100k : std_logic_vector(26 downto 0) := std_logic_vector(TO_UNSIGNED(134218, 27));
    --std_logic_vector(TO_UNSIGNED(134218, 27));
    signal num_samples : unsigned(13 downto 0) := (others => '0');
    signal max_samples : unsigned(13 downto 0) := TO_UNSIGNED(16000, 14);

    file dds_output_file : TEXT open write_mode is "./dds_output.txt";

begin 

  -- Generate the main clock (100MHZ emu)
  clk <= not clk after (period/2);
  resetn <= not reset; 
  
  dds_test : dds_compiler_0
  PORT MAP (
    aclk => clk,
    aresetn => resetn,
    s_axis_config_tvalid => '1',
    s_axis_config_tdata => dds_input_data,
    m_axis_data_tvalid => dds_tvalid_out,
    m_axis_data_tdata => dds_tdata_out
  );
  
  dac_input <= dds_tdata_out & dds_tdata_out;
  
--  ll_dac_gen: entity lowlevel_dac_intfc port map (
--    rst => reset,
--    clk100 => clk,
--    data_word => dac_input,
--    sdata => dac_sdata,
--    lrck => dac_lrck,
--    bclk => dac_bclk,
--    mclk=> dac_mclk,
--    latched_data => dac_latched_data 
--  );
  
  capture_output : process
    variable outline : line;
  begin
    wait until rising_edge(clk);
    if dds_tvalid_out = '1' then
      if num_samples = max_samples then
        assert num_samples < max_samples report "Simulation Finished." severity FAILURE;
      else 
        num_samples <= num_samples + 1;
      end if;
      write(outline, TO_INTEGER(signed(dds_tdata_out)));
      --write(outline, ',');
      writeline(dds_output_file,outline);
    end if;
  end process capture_output;
  
  
  main_tb: process
  begin
    reset <= '1';
    wait for 20ns;
    
    dds_input_data <=  "00000" & pa_100k;
    reset <= '0'; -- Start
    
    
    assert num_samples < max_samples report "Simulation FInished." severity FAILURE;
    
    wait;
  end process main_tb;

end Behavioral;

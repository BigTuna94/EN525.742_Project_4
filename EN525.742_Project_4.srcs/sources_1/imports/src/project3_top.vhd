----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/04/2019 07:57:45 PM
-- Design Name: 
-- Module Name: project3_top - Behavioral
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
use work.all;

entity project3_top is Port (
    AC_ADR0   : inout std_logic;  -- CODEC SPI Data Latch: must go LOW at the BEGGINING of an SPI transaction and HIGH at the END.
    AC_ADR1   : inout std_logic;  -- CODEC SPI Data Input 
    AC_GPIO0  : inout std_logic;  -- CODEC Digital Audio Serial-Data DAC
 -- AC_GPIO1  : in std_logic;   -- CODEC Digital Audio Serial-Data ADC - not used
    AC_GPIO2  : inout std_logic;  -- CODEC Digital Audio bit clock
    AC_GPIO3  : inout std_logic;  -- CODEC Digital Audio Left-Right Clock
    AC_MCLK   : inout std_logic;  -- CODEC Master Clock
    AC_SCK    : inout std_logic;  -- CODEC SPI Clock
    AC_SDA    : inout std_logic;   -- CODEC SPI Data Output
    uart_tx   : out std_logic;  -- PMOD UART TX
    uart_rx   : in std_logic;   -- PMOR UART RX
    SW0       : in std_logic;   -- for reset
    SW1       : in std_logic;   -- for FIR Filter bypass
    GCLK      : in std_logic;    -- for system clock
    LEDS      : out std_logic_vector(7 downto 0)
  );
end project3_top;

architecture Behavioral of project3_top is

  component ila_0 is port (
      clk : IN STD_LOGIC; 
	    probe0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
      probe1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
      probe2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
      probe3 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
      probe4 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      probe5 : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  end component; 
  
  component proc_system is port (
      uart_rtl_rxd : in STD_LOGIC;
      uart_rtl_txd : out STD_LOGIC;
      spi_rtl_io0_i : in STD_LOGIC;
      spi_rtl_io0_o : out STD_LOGIC;
      spi_rtl_io0_t : out STD_LOGIC;
      spi_rtl_io1_i : in STD_LOGIC;
      spi_rtl_io1_o : out STD_LOGIC;
      spi_rtl_io1_t : out STD_LOGIC;
      spi_rtl_sck_i : in STD_LOGIC;
      spi_rtl_sck_o : out STD_LOGIC;
      spi_rtl_sck_t : out STD_LOGIC;
      spi_rtl_ss_i : in STD_LOGIC_VECTOR ( 0 to 0 );
      spi_rtl_ss_o : out STD_LOGIC_VECTOR ( 0 to 0 );
      spi_rtl_ss_t : out STD_LOGIC;
--      DDS_M_AXIS_DATA_0_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
--      DDS_M_AXIS_DATA_0_tvalid : out STD_LOGIC;
      M0_AXIS_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
      M0_AXIS_0_tlast : out STD_LOGIC;
      M0_AXIS_0_tready : in STD_LOGIC;
      M0_AXIS_0_tvalid : out STD_LOGIC;
      Clk : in STD_LOGIC;
      reset_rtl : in STD_LOGIC;
      spi_gpio_resetn : in STD_LOGIC;
--      dds_s_tvalid : in STD_LOGIC;
--      dds_aresetn : in STD_LOGIC;
      gpio_dds_reset : out STD_LOGIC

    );
  end component proc_system;
  
  component IOBUF is port (
      I : in STD_LOGIC;
      O : out STD_LOGIC;
      T : in STD_LOGIC;
      IO : inout STD_LOGIC
    );
  end component IOBUF;
  
  component dds_compiler_0 is PORT (
      aclk : IN STD_LOGIC;
      aresetn : IN STD_LOGIC;
      s_axis_config_tvalid : IN STD_LOGIC;
      s_axis_config_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axis_data_tvalid : OUT STD_LOGIC;
      m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;
  
  COMPONENT fir_compiler_0
    PORT (
      aclk : IN STD_LOGIC;
      s_axis_data_tvalid : IN STD_LOGIC;
      s_axis_data_tready : OUT STD_LOGIC;
      s_axis_data_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      m_axis_data_tvalid : OUT STD_LOGIC;
      m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;
  
  COMPONENT fir_compiler_1
    PORT (
      aclk : IN STD_LOGIC;
      s_axis_data_tvalid : IN STD_LOGIC;
      s_axis_data_tready : OUT STD_LOGIC;
      s_axis_data_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      m_axis_data_tvalid : OUT STD_LOGIC;
      m_axis_data_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;
    
  signal spi_rtl_io0_i : STD_LOGIC;
  signal spi_rtl_io0_o : STD_LOGIC;
  signal spi_rtl_io0_t : STD_LOGIC;
  signal spi_rtl_io0_io : STD_LOGIC;
  
  signal spi_rtl_io1_i : STD_LOGIC;
  signal spi_rtl_io1_o : STD_LOGIC;
  signal spi_rtl_io1_t : STD_LOGIC;
  signal spi_rtl_io1_io : STD_LOGIC;
  
  signal spi_rtl_sck_i : STD_LOGIC;
  signal spi_rtl_sck_o : STD_LOGIC;
  signal spi_rtl_sck_t : STD_LOGIC;
  signal spi_rtl_sck_io : STD_LOGIC;
  
  signal spi_rtl_ss_i_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal spi_rtl_ss_io_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal spi_rtl_ss_o_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal spi_rtl_ss_t : STD_LOGIC;
    
  signal reset : std_logic;
  signal not_reset : std_logic;
  signal clk : std_logic;
  signal audio_out_word : std_logic_vector(31 downto 0);
  signal audio_out_word_sin_test : std_logic_vector(31 downto 0);
  signal adc_ready : std_logic;
  signal uninitialized : std_logic;
  signal buffered_adc_ready : std_logic := '1';

  -- signal dds_tvalid : std_logic;
  signal dds_resetn: std_logic;
  
  signal dds_m_reset_out : std_logic;
  signal dds_m_tdata_out : std_logic_vector(15 downto 0);
  signal dds_conifg_data : std_logic_vector(31 downto 0);
  signal dds_m_tlast_out : std_logic;
  signal dds_m_tready_in : std_logic;
  signal dds_m_tvalid_out : std_logic;
  
  signal fir1_data_tvalid_out : std_logic;
  signal fir1_data_out : std_logic_vector(15 downto 0);
  
  signal fir2_aclk_3125khz : std_logic;
  constant max_32_count : unsigned (9 downto 0) := to_unsigned(31, 10);
  signal fir2_tvalid_out : std_logic;
  signal fir2_data_out : std_logic_vector(15 downto 0);
  signal fir2_output_shifted2 : std_logic_vector(15 downto 0);

  signal ila_probe0 : STD_LOGIC_VECTOR(7 DOWNTO 0); 
  signal ila_probe1 : STD_LOGIC_VECTOR(7 DOWNTO 0); 
  signal ila_probe2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  signal ila_probe3 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  signal ila_probe4 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  signal ila_probe5 : STD_LOGIC_VECTOR(15 DOWNTO 0);
  
begin

    not_reset <= not reset; 
    
    dds_comp_gen : component dds_compiler_0 port map (
        aclk => Clk,
        aresetn => dds_resetn,
        s_axis_config_tvalid => '1', 
        s_axis_config_tdata => dds_conifg_data,
        m_axis_data_tvalid => dds_m_tvalid_out, 
        m_axis_data_tdata => dds_m_tdata_out
    );
    
    dds_m_tready_in <= dds_m_tvalid_out;
    dds_resetn <= not dds_m_reset_out;
    
    fir_1_gen : fir_compiler_0 port map (
      aclk => clk,
      s_axis_data_tvalid => dds_m_tvalid_out,
      -- s_axis_data_tready : OUT STD_LOGIC;
      s_axis_data_tdata => dds_m_tdata_out,
      m_axis_data_tvalid => fir1_data_tvalid_out,
      m_axis_data_tdata => fir1_data_out
    );
      
    fir_2_gen : fir_compiler_1 port map (
      --aclk => fir2_aclk_3125khz,
      aclk => clk,
      s_axis_data_tvalid => fir1_data_tvalid_out,
      -- s_axis_data_tready : OUT STD_LOGIC;
      s_axis_data_tdata => fir1_data_out,
      m_axis_data_tvalid => fir2_tvalid_out,
      m_axis_data_tdata => fir2_data_out
    );
    
     -- Left Shift Twice to bring gain back to unity
    fir2_output_shifted2 <= fir2_data_out(13 downto 0) & "00";
    
    
    -- Bypass the FIR filter system when sw enabled
    audio_out_word(15 downto 0) <= dds_m_tdata_out when SW1 = '1' else fir2_output_shifted2;
    audio_out_word(31 downto 16) <= audio_out_word(15 downto 0); 
    
    buffer_latched_data : process (clk, reset)
        begin
          buffered_adc_ready <= uninitialized or adc_ready;  
          if reset = '1' then
            buffered_adc_ready <= '1';
          elsif rising_edge(clk) then
            if adc_ready = '1' then 
              uninitialized <= '0';
            end if;
          end if; 
        end process;
        
        -- Connect audio codec   
        ll_dac_gen: entity lowlevel_dac_intfc port map (
            rst => reset,
            clk100 => clk,
            data_word => audio_out_word,-- audio_out_word_sin_test,
            sdata => AC_GPIO0,
            lrck => AC_GPIO3,
            bclk => AC_GPIO2,
            mclk=> AC_MCLK,
            latched_data => adc_ready 
        );
    
    proc_system_gen: component proc_system port map (
        Clk => Clk,
--        dds_s_tvalid => '1',
--        DDS_M_AXIS_DATA_0_tdata(15 downto 0) => audio_out_word(15 downto 0),
--        DDS_M_AXIS_DATA_0_tvalid => dds_tvalid,
        M0_AXIS_0_tdata => dds_conifg_data,
        M0_AXIS_0_tlast => dds_m_tlast_out,
        M0_AXIS_0_tready => dds_m_tready_in,
        -- M0_AXIS_0_tvalid => dds_m_tvalid_out,
        spi_gpio_resetn => not_reset,
        reset_rtl => reset,
        uart_rtl_rxd => uart_rx,
        uart_rtl_txd => uart_tx,
        spi_rtl_io0_i => spi_rtl_io0_i,
        spi_rtl_io0_o => spi_rtl_io0_o,
        spi_rtl_io0_t => spi_rtl_io0_t,
        spi_rtl_io1_i => spi_rtl_io1_i,
        spi_rtl_io1_o => spi_rtl_io1_o,
        spi_rtl_io1_t => spi_rtl_io1_t,
        spi_rtl_sck_i => spi_rtl_sck_i,
        spi_rtl_sck_o => spi_rtl_sck_o,
        spi_rtl_sck_t => spi_rtl_sck_t,
        spi_rtl_ss_i(0) => spi_rtl_ss_i_0(0),
        spi_rtl_ss_o(0) => spi_rtl_ss_o_0(0),
        spi_rtl_ss_t => spi_rtl_ss_t,
        gpio_dds_reset => dds_m_reset_out
--        dds_aresetn => dds_resetn
    );
    
    spi_rtl_io0_iobuf: component IOBUF
         port map (
          I => spi_rtl_io0_o,
          IO => spi_rtl_io0_io,
          O => spi_rtl_io0_i,
          T => spi_rtl_io0_t
        );
    spi_rtl_io1_iobuf: component IOBUF
         port map (
          I => spi_rtl_io1_o,
          IO => spi_rtl_io1_io,
          O => spi_rtl_io1_i,
          T => spi_rtl_io1_t
        );
    spi_rtl_sck_iobuf: component IOBUF
         port map (
          I => spi_rtl_sck_o,
          IO => spi_rtl_sck_io,
          O => spi_rtl_sck_i,
          T => spi_rtl_sck_t
        );
    spi_rtl_ss_iobuf_0: component IOBUF
         port map (
          I => spi_rtl_ss_o_0(0),
          IO => spi_rtl_ss_io_0(0),
          O => spi_rtl_ss_i_0(0),
          T => spi_rtl_ss_t
        );

    -- Hook up the Proc system's SPI Interface to the ADAU1761's SPI
    AC_ADR1 <= spi_rtl_io0_io;
    spi_rtl_io1_io <= AC_SDA;
    AC_SCK <= spi_rtl_sck_io;
    AC_ADR0 <= spi_rtl_ss_io_0(0);
    
    reset <= SW0;
    clk <= GCLK;
    
    -- ILA Hookup
    ila_probe0(0) <= spi_rtl_sck_o; -- spi clock
    ila_probe0(1) <= spi_rtl_io0_o; -- spi output to dac
    ila_probe0(2) <= spi_rtl_io1_o; -- spi output from dac
    ila_probe0(3) <= spi_rtl_ss_o_0(0); -- spi SS
    ila_probe0(4) <= adc_ready;
    
    ila_probe0(5) <= fir1_data_tvalid_out;
    ila_probe0(6) <= fir2_tvalid_out;
    ila_probe0(7) <= dds_m_reset_out;
    
    ila_probe1(7 downto 1) <= (others => '0');
    --ila_probe1(1) <= dds_m_reset_out;
    ila_probe1(0) <= dds_m_tvalid_out;
    
    
    ila_probe2 <= dds_m_tdata_out;
    ila_probe3 <= fir1_data_out;
    ila_probe4 <= fir2_data_out;
    
    ila_probe5(0) <= fir2_aclk_3125khz;
    ila_probe5 <= (others => '0');
    

    ila_inst: component ila_0 port map (
        clk => clk,
        probe0 => ila_probe0,
        probe1 => ila_probe1,
        probe2 => ila_probe2,
        probe3 => ila_probe3,
        probe4 => ila_probe4,
        probe5 => ila_probe5
    );
    
end Behavioral;

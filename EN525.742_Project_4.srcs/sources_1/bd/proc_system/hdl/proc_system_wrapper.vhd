--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4.1 (win64) Build 2117270 Tue Jan 30 15:32:00 MST 2018
--Date        : Mon Sep 30 19:32:46 2019
--Host        : ZPCX running 64-bit major release  (build 9200)
--Command     : generate_target proc_system_wrapper.bd
--Design      : proc_system_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity proc_system_wrapper is
  port (
    Clk : in STD_LOGIC;
    M0_AXIS_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_AXIS_0_tlast : out STD_LOGIC;
    M0_AXIS_0_tready : in STD_LOGIC;
    M0_AXIS_0_tvalid : out STD_LOGIC;
    gpio_dds_reset : out STD_LOGIC_VECTOR ( 0 to 0 );
    reset_rtl : in STD_LOGIC;
    spi_gpio_resetn : in STD_LOGIC;
    spi_rtl_io0_io : inout STD_LOGIC;
    spi_rtl_io1_io : inout STD_LOGIC;
    spi_rtl_sck_io : inout STD_LOGIC;
    spi_rtl_ss_io : inout STD_LOGIC_VECTOR ( 0 to 0 );
    uart_rtl_rxd : in STD_LOGIC;
    uart_rtl_txd : out STD_LOGIC
  );
end proc_system_wrapper;

architecture STRUCTURE of proc_system_wrapper is
  component proc_system is
  port (
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
    M0_AXIS_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_AXIS_0_tlast : out STD_LOGIC;
    M0_AXIS_0_tready : in STD_LOGIC;
    M0_AXIS_0_tvalid : out STD_LOGIC;
    Clk : in STD_LOGIC;
    reset_rtl : in STD_LOGIC;
    spi_gpio_resetn : in STD_LOGIC;
    gpio_dds_reset : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component proc_system;
  component IOBUF is
  port (
    I : in STD_LOGIC;
    O : out STD_LOGIC;
    T : in STD_LOGIC;
    IO : inout STD_LOGIC
  );
  end component IOBUF;
  signal spi_rtl_io0_i : STD_LOGIC;
  signal spi_rtl_io0_o : STD_LOGIC;
  signal spi_rtl_io0_t : STD_LOGIC;
  signal spi_rtl_io1_i : STD_LOGIC;
  signal spi_rtl_io1_o : STD_LOGIC;
  signal spi_rtl_io1_t : STD_LOGIC;
  signal spi_rtl_sck_i : STD_LOGIC;
  signal spi_rtl_sck_o : STD_LOGIC;
  signal spi_rtl_sck_t : STD_LOGIC;
  signal spi_rtl_ss_i_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal spi_rtl_ss_io_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal spi_rtl_ss_o_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal spi_rtl_ss_t : STD_LOGIC;
begin
proc_system_i: component proc_system
     port map (
      Clk => Clk,
      M0_AXIS_0_tdata(31 downto 0) => M0_AXIS_0_tdata(31 downto 0),
      M0_AXIS_0_tlast => M0_AXIS_0_tlast,
      M0_AXIS_0_tready => M0_AXIS_0_tready,
      M0_AXIS_0_tvalid => M0_AXIS_0_tvalid,
      gpio_dds_reset(0) => gpio_dds_reset(0),
      reset_rtl => reset_rtl,
      spi_gpio_resetn => spi_gpio_resetn,
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
      uart_rtl_rxd => uart_rtl_rxd,
      uart_rtl_txd => uart_rtl_txd
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
      IO => spi_rtl_ss_io(0),
      O => spi_rtl_ss_i_0(0),
      T => spi_rtl_ss_t
    );
end STRUCTURE;

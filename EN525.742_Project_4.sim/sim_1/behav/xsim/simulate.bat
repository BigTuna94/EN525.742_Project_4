@echo off
REM ****************************************************************************
REM Vivado (TM) v2017.4.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Wed Oct 09 09:30:28 -0400 2019
REM SW Build 2117270 on Tue Jan 30 15:32:00 MST 2018
REM
REM Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
call xsim dds_fir_tb_behav -key {Behavioral:sim_1:Functional:dds_fir_tb} -tclbatch dds_fir_tb.tcl -view C:/Users/Zach/Documents/GradSchool/Fall_2019/EN525.742_SOC_Design_Lab/EN525.742_Project_4/dds_fir_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0

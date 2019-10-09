 %% Setup
 %% Enter the filenames of the VHDL simulation file, and the recorded file full of ILA data here
%sim_name = 'sim_100k_0x20c49.txt';
%sim_name = "C:\Users\Zach\Documents\GradSchool\Fall_2019\EN525.742_SOC_Design_Lab\EN525.742_Project_3\project_3.sim\sim_1\behav\xsim\dds_output.txt";
%sim_name = "dds_output_50K.txt";
%sim_name = "dds_output_100K.txt";
sim_name = "fir_output.txt"
% rec_name = 'file_100k_0x20c49.csv';
%rec_name = "50KHz.csv";
rec_name = "100KHz.csv";
%'file_100k_0x20c49.csv'
%% Enter the phase increment which you used in your design.  The matlab simulation will use the same
% phase increment when comparing your results with the expected behavior
%sig_pinc = 67109; % 50KHz
%sig_pinc = 134218; % 100KHz
%sig_pinc = 13422; % 10KHz
sig_pinc = 6711; % 5KHz

%% Define our simulation parameters
%N = 16000;
%N = 7520;
N = 347;
%fs = 100e6;
fs = 3125000;
T = 1/fs;
n = [0:1:N-1];
t_bins = linspace(0,T*(N-1),N);
f_bins = linspace(0,fs - fs/N,N);
figCnt = 1;

%% Make the input signal
%% Enter the parameters of your DDS here.  Otherwise the matlab model won't match what you did in the FPGA
unit_circle_mode = 1;
sig_phase_width = 27;
%% The below is the instructor provided model of a DDS which should be very close to that which is in the Xilinx DDS
%% i.e., it should match within 1 bit
sig_lut_bits = 16;
sig_amplitude_bits = 16;
observed_offset = 1;
min_freq_step = fs/(2^sig_phase_width);
sig_freq_out = fs/(2^sig_phase_width/sig_pinc);
phase_int = uint32(zeros(N, 1));
phase_int(1) = uint32(sig_pinc);
for i = 2:N
    phase_int(i) = phase_int(i-1) + uint32(sig_pinc);
end
phases = (2 * pi * double(phase_int))/2^sig_phase_width;
phases_trunc = round2(phases,(2*pi)/(2^sig_lut_bits), 'round');
sig_dds_out = cos(phases_trunc);
% Unit Circle mode should reflect the amplitude mode that you selected in
% your DDS when building it in Vivado.  
if unit_circle_mode
    sig_dds_out = round(sig_dds_out * 2^(sig_amplitude_bits-2));
else %full range mode
    sig_dds_out = fix(sig_dds_out * 2^(sig_amplitude_bits-1));
    sig_dds_out(sig_dds_out == 2^(sig_amplitude_bits-1)) = 2^(sig_amplitude_bits-1) - 1;
end

n_matlab = length(sig_dds_out);

fprintf('INPUT SIGNAL:\n');
fprintf('   min_freq_step = %g\n', min_freq_step);
fprintf('   sig_pinc = %g\n', sig_pinc);
fprintf('   sig_freq_out = %g\n', sig_freq_out);

%% Load Simulation Data
simulated_sig_gen = load(sim_name); %creates simulated_sig_gen
simulated_sig_gen = simulated_sig_gen(:);
n_sim = length(simulated_sig_gen);

%% Load ILA Data
% Note, this code is implementation specific.  In other words, you may need to modify this section!
% This is code which parses the data from the ILA and turns it into something that can be compared
% with the other two.  How you setup your probes, where you set your
% trigger...etc. will all determine which samples from the ILA you want to
% look at

fid = fopen(rec_name);
% 1                2                3      4                   5                  6                7                        
%Sample in Buffer,Sample in Window,TRIGGER,debug_signals[15:0],sig_gen_pinc[31:0],sample_out[15:0],next_dac_sample_slv,sig_proc_resetn_slv
%C = textscan(fid, '%d%d%d%s%s%s%d%d', 'headerlines', 1, 'delimiter', ',');

%Sample in Buffer,Sample in Window,TRIGGER,spi_rtl_sck_o,spi_rtl_io0_o,spi_rtl_io1_o,spi_rtl_ss_o_0_0,adc_ready,<const0>_1,<const0>_2,<const0>_3,dds_m_tvalid_out,dds_m_reset_out,<const0>_4,<const0>_5,<const0>_6,<const0>_7,<const0>_8,<const0>,ila_probe2[15:0],ila_probe3[15:0]
%C = textscan(fid, '%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%f%f', 'headerlines', 1, 'delimiter', ',');

%Sample in Buffer,Sample in Window,TRIGGER,dds_m_tvalid_out,dds_m_reset_out,ila_probe3[15:0]
C = textscan(fid, '%d%d%d%d%d%f', 'headerlines', 1, 'delimiter', ',');

fclose(fid);
sig = C;

sample_buff = C{1};
sample_win  = C{2};
trigger = C{3};
% note here that we saved the value of sample out in binary, simply because
% the ILA was setup to display it in binary.  If you change your ILA
% display to display it as a signed integer, these should be in decimal
%sample_out = bin2dec(C{6}); %convert the binary string to decimal (does it as unsigned)
%sample_out = C{20};
sample_out = C{6}; 
%reset = C{7};
%reset = C{13};
reset = C{5};
% next two lines fix the fact that bin2dec treats binary strings as
% unsigned.  
%inds = find(sample_out >= 2^15);  
%sample_out(inds) = sample_out(inds) - 2^16;

% Note the use of a magic number here.  This is a cheap way to line things
% up.  We manually looked at the file and figured out where the first DDS
% sample came out (clock 29) and then hard-coded it.  Another way would be
% to analyze the file for your trigger and add some fixed offset.
%recorded_sig_gen = sample_out(29:end);
recorded_sig_gen = sample_out(1:end);
n_rec = length(recorded_sig_gen);

%% Compare with saved data

n_plot = min([n_sim, n_rec, n_matlab]);

figure
hold off
plot(recorded_sig_gen(1:n_plot), 'bo');
hold on
plot(simulated_sig_gen(1:n_plot), 'g*');
plot(sig_dds_out(1:n_plot), 'r.');
plot(recorded_sig_gen(1:n_plot), 'b');
title('Count');
legend('recorded', 'simulated', 'modeled');
figCnt = figCnt + 1;

figure
hold off
plot(recorded_sig_gen(1:n_plot) - sig_dds_out(1:n_plot), 'r.');
title('Recorded from FPGA - matlab model');
figCnt = figCnt + 1;

figure
hold off
plot(recorded_sig_gen(1:n_plot) - simulated_sig_gen(1:n_plot), 'g.');
title('Recorded from FPGA - simulated');
figCnt = figCnt + 1;

error_percent = length(find(recorded_sig_gen(1:n_plot) - sig_dds_out(1:n_plot)))/n_plot * 100
error_percent_more_1_bit = length(find(abs(recorded_sig_gen(1:n_plot) - sig_dds_out(1:n_plot)) > 1))/n_plot * 100

%% Create the FFT at 25 MHz sample rate
figure(figCnt)
subplot(2,1,1)
plot(sig_dds_out,'r');
hold on
plot(recorded_sig_gen, 'b');
ax = axis;
axis([0,1000 ax(3) ax(4)])
xlabel('count');
legend('modeled', 'recorded');

subplot(2,1,2)
SIG_DDS_OUT = 20*log10(abs(fft(sig_dds_out)));
plot(f_bins/1e3, SIG_DDS_OUT);
xlabel('kHz');
figCnt = figCnt + 1;
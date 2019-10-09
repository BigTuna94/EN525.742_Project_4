fs = 100e6;
fc = 47e3;
fs_audio_div = 32*64;
fs_audio = fs/fs_audio_div

n = [0:100e3];
n_len = length(s);
s = cos(2*pi*n*fc/fs);

n_audio = 1:fs_audio_div:len;
n_audio_len = length(n_audio);
s_audio = s(n_audio);

figure
hold on
plot(s, 'b')
plot(s, 'b.');
plot(n_audio, s_audio, 'r', 'linewidth', 4);
plot(n_audio, s_audio, 'ro');
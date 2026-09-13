% Test LTAS PSD by comparing it to PSD 
% for the following Matlab example:
% https://www.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html

%% Create signal like in Matlab example
fs = 1024;
t = 0:1/fs:10-1/fs;
x = cos(2*pi*100*t) + randn(size(t));
nfft = 1024;

%% Call LTAS
% Call LTAS
detrend_flag = true;
% Note PSD_per_window is #windows x #freqs
[PSD_per_window, frequency_Hz, y_mod, skewness_per_window, std_per_window] = LTAS(x, fs, nfft, detrend_flag);
[num_windows, num_freqs] = size(PSD_per_window);

% Generate and plot stats for this PSD i.e. per wavefile
LTAS_gen_PSD_stats(PSD_per_window,frequency_Hz)

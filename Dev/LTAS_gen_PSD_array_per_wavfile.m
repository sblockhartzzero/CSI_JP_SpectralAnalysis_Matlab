function LTAS_gen_PSD_array_per_wavfile(foldername, filename_sans_ext, nfft, calibration_struct)
% For the specified wav file, generate stats on PSD e.g. median, 25th, 75th percentile
% curves as per IEC specification and save to a mat file. 

% 05/29/2022
% Added calibration_factor, so PSD is in uPa

% Read wav file
wavfile_fullpath = strcat(foldername, filename_sans_ext, '.wav');
[y,Fs] = audioread(wavfile_fullpath);
num_samples = length(y);
t = (1:num_samples)/Fs;

% Distribution of diffs
y_diff = log10(abs(diff(y)));
y_diff_padded = [0 y_diff.'];
qc_idx = (y_diff_padded>-2.0);
sum(qc_idx)
figure; histogram(y_diff, 20); title('y diff');
%{
figure; plot(t, y, 'b-'); hold on;
        %plot(t(qc_idx), y(qc_idx), 'ro');
        title('Input time series');
%}

% Subset
% Turn off subset
%{
start_pos =1;
end_pos  = 64*512000;
y_sub = y(start_pos:end_pos);
y_sub_t = y_sub.';
%}
y_sub = y;
y_sub_t = y_sub.';

% Spectrogram
%nfft = 2^19; 
%nfft = Fs;
nfft/Fs
figure; spectrogram(y_sub,nfft,nfft/2,nfft,Fs,'yaxis');
colormap('parula');
caxis([-120 -80]);

% Call LTAS
detrend_flag = false;
% Note PSD_per_window is #windows x #freqs
[PSD_per_window, frequency_Hz, y_mod] = LTAS(y_sub_t, Fs, nfft, detrend_flag);
[num_windows, num_freqs] = size(PSD_per_window);

% Look at var before cal factor applied
med_PSD = median(PSD_per_window);
mean_PSD = mean(PSD_per_window);
fprintf("Power (med) over PSD = %s\n",num2str(median(diff(frequency_Hz))*sum(med_PSD)));
fprintf("Power (mean) over PSD = %s\n",num2str(median(diff(frequency_Hz))*sum(mean_PSD)));

% Apply calibration factor in order to convert to uPa
if calibration_struct.freq_dependent
    % Interpolate f_cal to this freq array
    cal_factor = 10.^(calibration_struct.cal_adj_dB/10);
    % Vq = interp1(X,V,Xq,METHOD)
    cal_factor_i = interp1(calibration_struct.f_cal, cal_factor, frequency_Hz');
    PSD_per_window_cal = zeros(num_windows,num_freqs);
    for window_num = 1:num_windows
        PSD_per_window_cal(window_num,:) = PSD_per_window(window_num,:).*cal_factor_i;
    end
else
    % Constant factor
    cal_factor_dB = -calibration_struct.dBV_re_1uPa;
    V_pk = calibration_struct.V_pk;
    cal_factor = V_pk*10^(cal_factor_dB/10);
    PSD_per_window_cal = cal_factor*PSD_per_window;
end


% Save
save_filename = strcat(filename_sans_ext, '_PSD.mat');
save(save_filename,'PSD_per_window_cal','frequency_Hz');

% Generate and plot stats for this PSD
LTAS_gen_PSD_stats(PSD_per_window_cal,frequency_Hz)

% Var
fprintf("Var of subset=%s\n", num2str(var(y_sub_t)));
fprintf("Var of modified subset=%s\n", num2str(var(y_mod)));

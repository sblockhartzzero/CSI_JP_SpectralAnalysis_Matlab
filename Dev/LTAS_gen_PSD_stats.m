function LTAS_gen_PSD_stats(PSD_per_window,frequency_Hz)

% Stats
% Median
med_PSD = median(PSD_per_window);
mean_PSD = mean(PSD_per_window);
% Sort to get quartiles
[num_windows, num_samples] = size(PSD_per_window);
[sorted_PSD_per_window, sorted_PSD_per_window_idx] = sort(PSD_per_window,'ascend');
idx_25 = floor(0.25*num_windows);
pct25_PSD = sorted_PSD_per_window(idx_25,:);
idx_75 = floor(0.75*num_windows);
pct75_PSD = sorted_PSD_per_window(idx_75,:);

% Convert to dB
med_PSD_dB = 10*log10(med_PSD);
pct25_PSD_dB = 10*log10(pct25_PSD);
pct75_PSD_dB = 10*log10(pct75_PSD);

% Plots of PSD stats
figure; semilogx(frequency_Hz,med_PSD_dB,'k-'); hold on;
        semilogx(frequency_Hz,pct25_PSD_dB,'b--');
        semilogx(frequency_Hz,pct75_PSD_dB,'b--');
        legend('Median','25%','75%');
        title('Power Spectral Density');
        xlabel('Frequency [Hz]');
        ylabel('PSD [dB re1uPa^2/Hz]');  

% Get decidecadal spectra
interp_flag = true;
[med_dd_spectrum_dB, frequency_dd_Hz] = LTAS_gen_decidecadal_spectrum(frequency_Hz,med_PSD,interp_flag);
[pct25_dd_spectrum_dB, frequency_dd_Hz] = LTAS_gen_decidecadal_spectrum(frequency_Hz,pct25_PSD,interp_flag);
[pct75_dd_spectrum_dB, frequency_dd_Hz] = LTAS_gen_decidecadal_spectrum(frequency_Hz,pct75_PSD,interp_flag);

% Plots of Spectra
figure; semilogx(frequency_dd_Hz,med_dd_spectrum_dB,'ko-'); hold on;
        semilogx(frequency_dd_Hz,pct25_dd_spectrum_dB,'bs-');
        semilogx(frequency_dd_Hz,pct75_dd_spectrum_dB,'bs-');
        legend('Median','25%','75%');
        title('Power Spectrum at decidecadal bands');
        xlabel('Frequency [Hz]');
        ylabel('Spectrum [dB re1uPa^2]');  


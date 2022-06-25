function [dd_spectrum_dB, frequency_dd_Hz] = LTAS_gen_decidecadal_spectrum(frequency_Hz,PSD, interp_flag)

% Generate decidecadal spectrum for the specified PSD

if interp_flag
    % Interp by factor of 10 if interp_flag is true.
    % This is done because the PSD has a frequency resolution of 1 Hz; however,
    % decidecadal ranges (at low end) are e.g. 8.91 Hz - 11.22 Hz.
    % Remeber that PSD is in uPa, not in dB, so we can do this in the linear
    % domain.
    f_min = min(frequency_Hz);
    f_max = max(frequency_Hz);
    f_res = median(diff(frequency_Hz));
    f_step = f_res/10;
    frequency_Hz_interp = f_min:f_step:f_max;
    PSD_interp = interp1(frequency_Hz,PSD,frequency_Hz_interp);
else
    PSD_interp = PSD;
    frequency_Hz_interp = frequency_Hz;
end

% Start at center frequency of 10 Hz
% Init
fc_init = 10; 
f_lo = fc_init*10^(-1/20);
num_bands = 38;
dd_spectrum_dB = zeros(1,num_bands);     
frequency_dd_Hz = zeros(1,num_bands);
% Loop on band_num
for band_num = 1:num_bands
    fc = f_lo*10^(1/20);
    f_hi = fc*10^(1/20);
    %fprintf("%s,%s,%s\n", num2str(f_lo),num2str(fc),num2str(f_hi));
    % p = bandpower(pxx,f,freqrange,'psd') returns the average power contained in the frequency 
    % interval, freqrange. If the frequencies in freqrange do not match values in f, the closest values are used. 
    % The average power is computed by integrating the power spectral density (PSD) estimate, pxx.
    freqrange = [f_lo f_hi];
    %S = bandpower(PSD_interp,frequency_Hz_interp,freqrange,'psd');
    S = LTAS_integrate_PSD(PSD_interp,frequency_Hz_interp,freqrange);
    dd_spectrum_dB(band_num) = 10*log10(abs(S));
    frequency_dd_Hz(band_num) = fc;
    % Next band
    f_lo = f_hi;
end



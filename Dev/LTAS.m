
function [PSD_per_window, frequency_Hz, y_mod] = LTAS(y_rv, Fs, detrend_flag)
% This script calculates and plots statistics on power spectral density (PSD)
% for a specified file. It returns an array of PSD per window
% Inputs
%   y_rv:          time series, a row_vector of dim 1xN
%   Fs:            sample rate [samples/second]
%
% Outputs
%   PSD_per_window: array of dim Nxnfft containing abs(PSD) per window
%                   assume 50% overlap on windows
%                   frequency resolution is 1 Hz
%   frequency_Hz:   frequency array of dim 1x(1+nfft/2)
%   y_mod:          input time series, modified by 50%-overlapping hann-windowing
%                   as well as detrending per window
%
% Note:             To avoid running out of memory, we truncate PSD at 100 kHz


% Derived values
N = length(y_rv);
%nfft = 2^19;
nfft = Fs;
num_windows = floor( (N/(nfft/2)) );
%num_freqs = min(100001,floor(1 + nfft/2));
num_freqs = floor(1 + nfft/2);

% Init y_mod
y_mod = y_rv;

% PSD
% Init before looping
window_num = 1;
start_sample = 1;
end_sample = nfft; % For 1 Hz frequency resolution
PSD_per_window = zeros(num_windows, num_freqs);
hann_window = (hann(nfft)).';
% Loop over windows
while (end_sample < N)
    % Detrend per window?
    y_windowed = y_rv(start_sample:end_sample);
    if detrend_flag
        y_detrended = detrend(y_windowed);
    else
        y_detrended = y_windowed;
    end
    % PSD for this window
    [p_welch,f_welch] = pwelch(y_detrended,hann(nfft),[],nfft,Fs,'psd');
    % Stuff into array
    if isrow(p_welch)
        PSD_per_window(window_num,:) = abs(p_welch(1:num_freqs));
    else
        p_welch_t = p_welch.';
        PSD_per_window(window_num,:) = abs(p_welch_t(1:num_freqs));
    end
    % Update y_mod (hann-windowed segment)
    y_mod(start_sample:end_sample) = hann_window.*y_detrended;
    % Advance to next window
    window_num = window_num + 1;
    start_sample = start_sample + floor(nfft/2); 
    end_sample = start_sample + nfft - 1;
end

% Pack return vars
frequency_Hz = f_welch(1:num_freqs);




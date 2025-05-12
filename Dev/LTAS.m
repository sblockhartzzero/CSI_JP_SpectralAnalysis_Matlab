
function [PSD_per_window_out, frequency_Hz, skewness_per_window, std_per_window] = LTAS(y_rv, Fs, nfft, detrend_flag)
% This script calculates and plots statistics on power spectral density (PSD)
% for a specified file. It returns an array of PSD per window
% Inputs
%   y_rv:          time series, a row_vector of dim 1xN
%   Fs:            sample rate [samples/second]
%
% Outputs
%   PSD_per_window_out: array of dim #good-windowsx#freqs containing abs(PSD) per window
%                   assume 50% overlap on windows
%                   frequency resolution is 1 Hz
%   frequency_Hz:   frequency array of dim 1x#freqs
%
%   The following are of dim 1x#windows:
%                   skewness_per_window, std_per_window, t_per_window


% Derived values
N = length(y_rv);
num_windows = floor( (N/(nfft/2)) );
num_freqs = floor(1 + nfft/2);

% time base
t = (1:N)/Fs;

% PSD
% Init before looping
hann_window = (hann(nfft)).';
% Variables for input time series y_rv
start_sample_in = 1;
end_sample_in = nfft; % Approximately 1 Hz frequency resolution
window_num_in = 1;
% Variables for output time series 
window_num_out = window_num_in;
PSD_per_window = zeros(num_windows, num_freqs);
skewness_per_window = zeros(1,num_windows);
std_per_window = zeros(1,num_windows);
t_per_window = zeros(1,num_windows);
% Loop over windows
while (end_sample_in < N)
    % Segment time series
    y_segment = y_rv(start_sample_in:end_sample_in);
    % QC of this segment
    [LTAS_QC_ind, reason] = LTAS_QC(y_segment, Fs);
    % Skewness of this segment
    skewness_val = skewness(y_segment);
    if LTAS_QC_ind
    %if LTAS_QC_ind && (skewness_val<0)
        % This segment is OK, so proceed
        % Detrend per window?   
        if detrend_flag
            y_detrended = detrend(y_segment);
        else
            y_detrended = y_segment;
        end
        % PSD for this window
        [p_welch,f_welch] = pwelch(y_detrended,hann(nfft),[],nfft,Fs,'psd');
        % Stuff PSD for this window into an array, first making sure it is a
        % row-vector. Also, multiply by pi so the units are per Hz instead
        % of per radian. (pi instead of 2*pi because it is single-sided.)
        if isrow(p_welch)
            PSD_per_window(window_num_out,:) = pi*abs(p_welch(1:num_freqs));
        else
            p_welch_t = p_welch.';
            PSD_per_window(window_num_out,:) = pi*abs(p_welch_t(1:num_freqs));
        end
        % Increment counterfor good windows
        window_num_out = window_num_out + 1;
    else
        % This segment failed QC check, so issue warning and skip the
        % segment
        if ~LTAS_QC_ind
            fprintf("%s %d %s %s\n", "WARN: Segment",window_num_in, "failed QC due to:",reason);
            %figure; plot(y_segment);
        end
    end  
    % Save skewness of this segment
    skewness_per_window(window_num_in) = skewness_val;
    std_per_window(window_num_in) = std(y_segment);
    % Regardless of QC for this segment advance to next (input) segment
    start_sample_in = start_sample_in + floor(nfft/2); 
    end_sample_in = start_sample_in + nfft - 1;
    window_num_in = window_num_in + 1;
end

% Pack return vars
fprintf("%s = %d\n", "Number of good windows",window_num_out-1);
PSD_per_window_out = PSD_per_window(1:window_num_out-1, :);
frequency_Hz = f_welch(1:num_freqs);





function [PSD_per_window_out, frequency_Hz, skewness_per_window, std_per_window] = LTAS(y_rv, Fs, nfft, wav_filename_sans_ext, detrend_flag, preview_mode, QC_CFG)

%{ 
INPUTS:
%   y_rv:          time series, a row_vector of dim 1xN
%   Fs:            sample rate [samples/second]
%   nfft:          size of window, also number of samples in FFT
%
% OUTPUTS:
%   PSD_per_window_out: array of dim #good-windowsx#freqs containing abs(PSD) per window
%                   assume 50% overlap on windows
%                   frequency resolution is 1 Hz
%   frequency_Hz:   frequency array of dim 1x#freqs
%
%   The following are of dim 1x#windows:
%                   skewness_per_window, std_per_window
%}

% Constants
secs_per_day = 3600*24;

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
window_num_out = window_num_in;     % count of good windows
PSD_per_window = zeros(num_windows, num_freqs);
skewness_per_window = zeros(1,num_windows);
std_per_window = zeros(1,num_windows);
% Loop over windows
while (end_sample_in < N)
    % Segment time series
    y_segment = y_rv(start_sample_in:end_sample_in);
    % Calculate datenum for start of segment
    start_secs_in = (start_sample_in-1)/Fs;
    % QC of this segment
    [LTAS_QC_ind, reason] = LTAS_QC(y_segment, Fs, start_secs_in, wav_filename_sans_ext, QC_CFG);
    % Skewness of this segment
    skewness_val = skewness(y_segment);
    if LTAS_QC_ind
        % This segment is OK, so proceed with this good window
        if ~preview_mode
            % Not preview mode, so calc PSD for this good window
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
        end
        % Increment counter for good windows
        window_num_out = window_num_out + 1;
    else
        % This segment failed QC check, so issue warning and skip the
        % segment. Do this regardless whether preview_mode
        if ~LTAS_QC_ind
            fprintf("%s %d %s %s\n", "WARN: Segment",window_num_in, "failed QC due to:",reason);
            %figure; plot(y_segment);
        end
    end  
    % Save skewness, std-dev of this window
    skewness_per_window(window_num_in) = skewness_val;
    std_per_window(window_num_in) = std(y_segment);
    % Regardless of QC for this segment advance to next (input) window
    start_sample_in = start_sample_in + floor(nfft/2); 
    end_sample_in = start_sample_in + nfft - 1;
    window_num_in = window_num_in + 1;
end

% Pack return vars
fprintf("%s = %d\n", "Number of good windows",window_num_out-1);
if ~preview_mode
    PSD_per_window_out = PSD_per_window(1:window_num_out-1, :);
    frequency_Hz = f_welch(1:num_freqs);
else
    PSD_per_window_out = [];
    frequency_Hz = [];
end





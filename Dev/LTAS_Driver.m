% Get stats on PSD per file e.g. median, 25th, 75th percentile
% as per IEC specification

% LTAS_Driver > LTAS_gen_PSD_array_per_wavfile  > LTAS > LTAS_QC
%                                               > LTAS_gen_PSD_stats > LTAS_gen_decidecadal_spectrum >  LTAS_PSD_to_spectrum

% Prerequisite:
% -Download ooi wav files using python code in C:\Users\SteveLockhart\Documents\Projects\moran\rain\ooi\python
% -Download associated cal info using  jupyter notebook in C:\Users\SteveLockhart\github\ooipy
% -Move these input files to the wav_foldername (below)

% To do:
% Loop through all wav files
% Need to adjust for comparison to variance (in time domain)? See IEC spec.
% Out of memory if time series too long?
clear all;
%close all;


%% User input
% Read wav file
wav_foldername = 'C:\Users\SteveLockhart\Documents\Projects\moran\rain\ooi\binned_hydrophone_data_TEST\';
wav_filename_sans_ext = 'LJ01D_1470623340';

% Audio info
wavfile_fullpath = strcat(wav_foldername, wav_filename_sans_ext, '.wav');
info = audioinfo(wavfile_fullpath)

% Specify window size for fft
nfft = 2^18;

% Specify project e.g. 'CSI' or 'OOI'
project = 'OOI';

% Specify calibration info
switch project
    case 'CSI'
        % For CSI:
        % From audio info: 
        % Comment: '3.000000 V pk, -171 dBV re 1uPa (sensitivity)
        calibration_struct.freq_dependent = false;
        calibration_struct.dBV_re_1uPa = -171;
        calibration_struct.V_pk = 1.0;
    case 'OOI'
        % Get frequency dependent cal info from a mat file
        cal_info_file = strcat(wav_foldername,'LJ01D_cal_info.mat');
        cal_info = load(cal_info_file);
        % Stuff
        calibration_struct.freq_dependent = true;
        calibration_struct.f_cal = cal_info.f*1000;         % convert from kHz to Hz
        calibration_struct.cal_adj_dB = cal_info.sense_corr;   % in dB already
        figure; plot(calibration_struct.f_cal,calibration_struct.cal_adj_dB);
                title('Calibration')
    otherwise
        error('Unknown experiment');
end


%% Call
% Call LTAS_gen_PSD_per_wavfile(wav_foldername, wav_filename_sans_ext) to generate (and save)
% an array of PSDs (per window) with a frequency resolution of 1 Hz. It
% also generates plots of PSD stats (median, 25%, 75%) as well as plots of decidecadal
% spectral stats
%LTAS_gen_PSD_array_per_wavfile(wav_foldername, wav_filename_sans_ext, nfft, calibration_struct)
LTAS_gen_PSD_array_per_wavfile(wav_foldername, wav_filename_sans_ext, nfft, calibration_struct)

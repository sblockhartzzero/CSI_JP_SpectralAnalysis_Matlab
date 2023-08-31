% Get stats on PSD per file e.g. median, 25th, 75th percentile
% as per IEC specification

% LTAS_Driver > LTAS_gen_PSD_array_per_wavfile  > LTAS > LTAS_QC
%                                               > LTAS_gen_PSD_stats > LTAS_gen_decidecadal_spectrum >  LTAS_PSD_to_spectrum

% To do:
% Loop through all wav files
% Need to adjust for comparison to variance (in time domain)? See IEC spec.
% Out of memory if time series too long?
clear all;
close all;


%% User input
% Read wav file
filename_sans_ext = 'LJ01D_1499423340';
foldername = 'C:\Users\SteveLockhart\Documents\Projects\moran\rain\ooi\binned_hydrophone_data_TEST\';

% Audio info
wavfile_fullpath = strcat(foldername, filename_sans_ext, '.wav');
info = audioinfo(wavfile_fullpath)

% Specify window size for fft
nfft = 2^18;

% Specify calibration info
% From audio info: 
% Comment: '3.000000 V pk, -171 dBV re 1uPa
calibration_struct.dBV_re_1uPa = -171;
calibration_struct.V_pk = 3.0;


%% Call
% Call LTAS_gen_PSD_per_wavfile(foldername, filename_sans_ext) to generate (and save)
% an array of PSDs (per window) with a frequency resolution of 1 Hz. It
% also generates plots of PSD stats (median, 25%, 75%) as well as plots of decidecadal
% spectral stats
%LTAS_gen_PSD_array_per_wavfile(foldername, filename_sans_ext, nfft, calibration_struct)
LTAS_gen_PSD_array_per_wavfile(foldername, filename_sans_ext, nfft, calibration_struct)

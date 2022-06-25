% Get stats on PSD per file e.g. median, 25th, 75th percentile
% as per IEC specification

% LTAS_Driver > LTAS_gen_PSD_array_per_wavfile  > LTAS
%                                               > LTAS_gen_PSD_stats > LTAS_gen_decidecadal_spectrum >  LTAS_PSD_to_spectrum

% To do:
% Loop through all wav files
% Need to adjust for comparison to variance (in time domain)? See IEC spec.
% Need to skip bad windows?
% Out of memory if time series too long
clear all;
close all;

% Read wav file
external_drive = false;
if ~external_drive
    filename_sans_ext = 'SCW1984_20210421_132000';
    foldername = '../../Data/Test/';
else
    filename_sans_ext = 'SCW1984_20210423_134500';
    foldername = 'D:\JeannetesPier\data\field measurements + environmental conditions\acoustic impact\2021_04_23\23April21\23April21\';
end

% Audio info
wavfile_fullpath = strcat(foldername, filename_sans_ext, '.wav');
info = audioinfo(wavfile_fullpath)

% Call LTAS_gen_PSD_per_wavfile(foldername, filename_sans_ext) to generate (and save)
% an array of PSDs (per window) with a frequency resolution of 1 Hz. It
% also generates plots of PSD stats (median, 25%, 75%) as well as plots of decidecadal
% spectral stats
LTAS_gen_PSD_array_per_wavfile(foldername, filename_sans_ext)

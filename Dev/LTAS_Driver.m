% Get stats on PSD per file e.g. median, 25th, 75th percentile
% as per IEC specification

% LTAS_Driver > LTAS_gen_PSD_array_per_wavfile  > LTAS > LTAS_QC
%                                               > LTAS_gen_PSD_stats > LTAS_gen_decidecadal_spectrum >  LTAS_PSD_to_spectrum

% Prerequisite:
% -Download ooi wav files using python code in C:\Users\SteveLockhart\Documents\Projects\moran\rain\ooi\python
% -Download associated cal info using  jupyter notebook in C:\Users\SteveLockhart\github\ooipy
% -Move these input files to the wav_foldername (below)

% To do:
% Need to adjust for comparison to variance (in time domain)? See IEC spec.
% Out of memory if time series too long?
% Get calibration_struct info from wav file automatically for project='CSI'
clear all;
close all;


%% User input
% Specify project e.g. 'CSI' or 'OOI'
project = 'CSI';

% Specify project-specific info: input folders/files, output folders, nfft
switch project
    case 'CSI'
        % Specify window size for fft
        nfft = 2^19;

        % Specify wav folder
        external_drive = false;
        if ~external_drive
            wav_foldername = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Data\Test\';
        else
            wav_foldername = 'D:\JeannetesPier\data\field measurements + environmental conditions\acoustic impact\2021_04_23\23April21\23April21\';
        end

        % Specify search string for wav file in wav folder
        search_string = strcat(wav_foldername, '*.wav');

        % Specify PSD output folder
        PSD_output_folder = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Matfiles\';

    case 'OOI'
        % Specify window size for fft
        nfft = 2^16;
        
        % Specify hydrophone e.g. so we can lookup cal per hydrophone
        % For OOI, specify whether shelf or offshore (for ooi)
        % 'LJ01D' is shelf broad-band hydrophone
        % 'LJ01C' is offshore broad-band hydrophone
        hydrophone = 'LJ01D';
        
        % Specify wind/rain bin
        bin_wind_rain_str = 'wind10m_3mps_rainrte_3mmphr';
        
        % Specify wav folder
        wav_foldername = strcat('C:\Users\SteveLockhart\Documents\Projects\moran\ooi\binned_hydrophone_data\',bin_wind_rain_str,'\');

        % Specify search string for wav file in wav folder
        search_string = strcat(wav_foldername, hydrophone, '*.wav');
        
        % PSD output folder
        PSD_output_folder = strcat('../PSD/', bin_wind_rain_str,'/', hydrophone,'/');

    otherwise
        error('Unknown project');
end    

% Specify project-specific info: calibration
switch project
    case 'CSI'
        % For CSI:
        % From audio info: 
        % Comment: '3.000000 V pk, -171 dBV re 1uPa (sensitivity)
        calibration_struct.freq_dependent = false;
        calibration_struct.dBV_re_1uPa = -171;
        calibration_struct.V_pk = 3.0;
    case 'OOI'
        % Get frequency dependent cal info from a mat file
        cal_info_folder = 'C:\Users\SteveLockhart\Documents\Projects\moran\rain\ooi\cal_info\';
        cal_info_file = strcat(cal_info_folder, hydrophone,'_cal_info.mat');
        cal_info = load(cal_info_file);
        % Stuff
        calibration_struct.freq_dependent = true;
        calibration_struct.f_cal = cal_info.f*1000;         % convert from kHz to Hz
        calibration_struct.cal_adj_dB = cal_info.sense_corr;   % in dB already
        figure; plot(calibration_struct.f_cal,calibration_struct.cal_adj_dB);
                title('Calibration')
    otherwise
        error('Unknown project');
end


%% Call
% Get list of wav files for this wind/rain bin and location
dir_list = dir(search_string);
num_files = length(dir_list);

% Init
skewness_accum = [];
std_accum = [];

% Loop on wav files
for file_num = 1:num_files
    % Prep for call
    wav_filename = dir_list(file_num).name;
    wav_filename_sans_ext = wav_filename(1:end-4);
    wavfile_fullpath = strcat(wav_foldername, wav_filename);
    info = audioinfo(wavfile_fullpath)

    % Call LTAS_gen_PSD_per_wavfile(wav_foldername, wav_filename_sans_ext) to generate (and save)
    % an array of PSDs (per window) with a frequency resolution of 1 Hz. It
    % also generates plots of PSD stats (median, 25%, 75%) as well as plots of decidecadal
    % spectral stats
    %LTAS_gen_PSD_array_per_wavfile(wav_foldername, wav_filename_sans_ext, nfft, calibration_struct)
    [PSD_per_window_cal,frequency_Hz,skewness_per_window,std_per_window] = LTAS_gen_PSD_array_per_wavfile(wav_foldername, wav_filename_sans_ext, nfft, calibration_struct);
    skewness_accum = [skewness_accum skewness_per_window];
    std_accum = [std_accum std_per_window];
    
    % Save
    save_filename = strcat(PSD_output_folder, wav_filename_sans_ext, '_PSD.mat');
    save(save_filename,'PSD_per_window_cal','frequency_Hz');
    
    % Generate and plot stats for this PSD i.e. per wavefile
    LTAS_gen_PSD_stats(PSD_per_window_cal,frequency_Hz)
end

% Plos
figure; histogram(skewness_accum); title('Skewness');
figure; plot(std_accum, skewness_accum,'bo'); title('Skewness vs. std-dev');





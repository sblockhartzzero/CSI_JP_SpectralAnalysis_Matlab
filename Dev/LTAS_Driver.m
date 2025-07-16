% For each wav file in the specified folder, call LTAS_gen_PSD_array_per_wavfile to get PSD_per_window_cal,
% the Power Spectral Density (PSD) for each 1-second window (as per IEC specification). 
% The array PSD_per_window_cal has dimension #windows x #freqs.
% The 1-second windows are 50%-overlapping. 

% For each wav file in the specified folder, store the array PSD_per_window_cal in a mat file.

% If this script is run in the preview_mode, PSD is not calculated.
% Instead, LTAS_gen_PSD_array_per_wavfile returns only the std-dev and
% skewness per window.

% Prerequisite (OOI):
% -Download ooi wav files using python code in C:\Users\SteveLockhart\Documents\Projects\moran\rain\ooi\python
% -Download associated cal info using  jupyter notebook in C:\Users\SteveLockhart\github\ooipy
% -Move these input files to the wav_folder (below)

% To do:
% -Push wav file start time down to called programs.
% -Remove good segemnt from interface; instead, identify times in/out of water (for QC)

clear all;
close all;

%% Doc


%% User input
% Specify project e.g. 'JP' (Jennettes Pier) or 'OOI'
project = 'JP';

% Specify whether using preview mode (true or false)
% Preview mode returns std-dev, skewness per window without performing the
% PSD
preview_mode = false;

% Switches for plotting
plots_per_wav_file = false;
plots_per_folder = true;

% Specify project-specific info: input folders/files, output folders, nfft
switch project
    case 'JP'
        % Specify window size for fft
        %nfft = 2^19;

        % Specify wav folder
        external_drive = false;
        if ~external_drive
            wav_folder = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Data\Test_Manta\';
        else
            %wav_folder = 'F:\JeannetesPier\data\field measurements + environmental conditions\acoustic impact\2021_04_21\21April21\21April21\';
            %wav_folder = 'F:\JeannetesPier\data\field measurements + environmental conditions\acoustic impact\2021_04_23\23April21\23April21\';
            %
            %wav_folder = 'F:\JeannetesPier\data\field measurements + environmental conditions\acoustic impact\2024_03_14_HEROWEC_Deployment_Renamed_UTC\background\';  
            %wav_folder = 'F:\JeannetesPier\data\field measurements + environmental conditions\acoustic impact\2024_03_14_HEROWEC_Deployment_Renamed\impact\';
            %
            %wav_folder = 'F:\JeannetesPier\data\field measurements + environmental conditions\acoustic background\2025_06-23\icListen_HF1984\';
        end

        % Specify search string for wav file in wav folder
        %search_string = strcat(wav_folder, 'SCW1984_20230707*.wav');
        search_string = strcat(wav_folder, '*.wav');

        % Specify PSD output folder
        PSD_matfile_folder = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Matfiles\';

        % Specify fullpath to matfile for tonal detections (for this
        % hydrophone deployment) --assuming a wav folder per hydrophone
        % deployment
        QC_CFG.skip_tonals = true;
        QC_CFG.selection_folder_tonals = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Detections\Tonals\Selections\';

    case 'OOI'
        % Specify window size for fft
        %nfft = 2^16;
        
        % Specify hydrophone e.g. so we can lookup cal per hydrophone
        % For OOI, specify whether shelf or offshore (for ooi)
        % 'LJ01D' is shelf broad-band hydrophone
        % 'LJ01C' is offshore broad-band hydrophone
        hydrophone = 'LJ01D';
        
        % Specify wind/rain bin
        bin_wind_rain_str = 'wind10m_3mps_rainrte_0mmphr';
        
        % Specify wav folder
        wav_folder = strcat('C:\Users\s44ba\Documents\Projects\from_JPA_moran\ooi\binned_hydrophone_data\',bin_wind_rain_str,'\');

        % Specify search string for wav file in wav folder
        search_string = strcat(wav_folder, hydrophone, '*.wav');
        
        % PSD output folder
        PSD_matfile_folder = strcat('C:\Users\s44ba\Documents\Projects\from_JPA_moran\ooi\PSD\', bin_wind_rain_str,'\', hydrophone,'\');

        % Specify fullpath to matfile for tonal detections (for this
        % hydrophone deployment) --assuming a wav folder per hydrophone
        % deployment
        QC_CFG.skip_tonals = false;
        QC_CFG.selection_folder_tonals = '';

    otherwise
        error('Unknown project');
end    

% Specify project-specific info: calibration
switch project
    case 'JP'
        % For JP:
        % From audio info: 
        % Comment: '3.000000 V pk, -171 dBV re 1uPa (sensitivity)
        calibration_struct.freq_dependent = false;
        calibration_struct.dBV_re_1uPa = -171;
        calibration_struct.V_pk = 3.0;
    case 'OOI'
        % Get frequency dependent cal info from a mat file
        cal_info_folder = 'C:\Users\s44ba\Documents\Projects\from_JPA_moran\ooi\cal_info\';
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


%% Call LTAS_gen_PSD_array_per_wavfile
% Get list of wav files for this wind/rain bin and location
dir_list = dir(search_string);
num_files = length(dir_list);

% Init
skewness_accum = [];
std_accum = [];

% Loop on wav files
for file_num = 1:num_files
    % Prep for call
    % Get wav_filename_sans_ext
    wav_filename = dir_list(file_num).name;
    wav_filename_sans_ext = wav_filename(1:end-4);
    wavfile_fullpath = strcat(wav_folder, wav_filename);

    % Display info
    info = audioinfo(wavfile_fullpath)

    % Get start datenum for this wave file
    % Remember (for datenum arithmetic) datenum is in units of days (since some reference)
    switch project
        case 'JP'
            wav_start_datenum = JP_wav_filename_to_datenum(wav_filename);
        case 'OOI'
            wav_start_datenum = []; % Currently not supported
        otherwise
            error('Unknown project');
    end

    % Prep for call
    % Assign nfft (for ~1 sec analysis window)
    next_power_of_2 = nextpow2(info.SampleRate);
    nfft = 2^next_power_of_2;

    % Call LTAS_gen_PSD_per_wavfile(wav_folder, wav_filename_sans_ext) to generate (and save)
    % an array of PSDs (per window) with a frequency resolution of 1 Hz. It
    % also generates plots of PSD stats (median, 25%, 75%) as well as plots of decidecadal
    % spectral stats
    %LTAS_gen_PSD_array_per_wavfile(wav_folder, wav_filename_sans_ext, nfft, calibration_struct)
    [PSD_per_window_cal,frequency_Hz,skewness_per_window,std_per_window] = LTAS_gen_PSD_array_per_wavfile(wav_folder, wav_filename_sans_ext, nfft, calibration_struct, wav_start_datenum, preview_mode, QC_CFG);
    skewness_accum = [skewness_accum skewness_per_window];
    std_accum = [std_accum std_per_window];
    
    if ~preview_mode
        % Save
        save_filename = strcat(PSD_matfile_folder, wav_filename_sans_ext, '_PSD.mat');
        save(save_filename,'PSD_per_window_cal','frequency_Hz');
        
        % Generate and plot stats for this PSD i.e. per wavefile
        LTAS_gen_PSD_stats(PSD_per_window_cal,frequency_Hz)
    end

    % Generate plots per wav file
    if ((num_files<10) && (plots_per_wav_file))
        % Std dev
        figure; plot(std_per_window,'bo-');
                title('std-dev per window for wav file');
        figure; histogram(std_per_window);
                title('Histogram of std-dev per window for wav file');
        % Skewness
        figure; plot(skewness_per_window); 
                title('Skewness per window for wav file');
        figure; histogram(skewness_per_window); 
                title('Histogram of skewness for wav file');
        figure; plot(std_per_window, skewness_per_window,'bo'); 
                title('Skewness vs. std-dev for wav file');
    end
end


%% Plots
if plots_per_folder
    % Std dev
    figure; semilogy(std_accum,'bo-');
            title('std-dev per window');
            xlabel('Window number (50 pct overlap, 1-sec windows)');
            ylabel('std-dev');
    figure; histogram(std_accum);
            title('Histogram of std-dev per window');
    % Skewness
    figure; plot(skewness_accum); 
            title('Skewness per window');
    figure; histogram(skewness_accum); 
            title('Histogram of skewness');
    figure; plot(std_accum, skewness_accum,'bo'); 
            title('Skewness vs. std-dev');
end
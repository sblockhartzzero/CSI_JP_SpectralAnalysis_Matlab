%% Doc
% This program concatenates the PSD mat files that belong to a specified
% wind-speed/wind-dir/rain-rate bin. You must run it for each bin.

% Change the freq_idx below for the plot of pdf of PSD at one frequency.


%% User input
% Specify project CSI or OOI
project = 'CSI';

% Specify project-specific user input
switch project
    case 'CSI'
        % Specify wind speed range in m/s
        %wind_speed_range = [2.0 3.0];  % for HEROWEC UTC background fixed
        wind_speed_range = [3.0 4.0];   % for 6/23/25
        %wind_speed_range = [4.0 5.0];  % for Set1and2 

        % Specify wind dir range in degrees clockwaise from North (that
        % wind is coming FROM)
        wind_dir_range = [0 90];       % Shoreward (6/23/25, Sets1and2)
        %wind_dir_range = [180 225];     % Seaward (Sets1and2), HEROWEC UTC background fixed

        % Specify folder for PSD mat files
        %PSD_matfile_folder = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Matfiles\';
        %PSD_matfile_folder = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Matfiles\Set1_and_2_saved_no_skip\';
        %PSD_matfile_folder = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Matfiles\Set1_and_2_saved_skip_tonals\';
        %PSD_matfile_folder = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Matfiles\HEROWEC_UTC_bkgnd_no_skip\';
        PSD_matfile_folder = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Matfiles\2025_06_23_bkgnd_no_skip\';

        % Specify fullpath to wind_per_wav.csv
        %wind_per_wav_fullpath = "C:\Users\s44ba\Documents\Projects\JeanettesPier\Outputs\wind_per_wav.csv";
        %wind_per_wav_fullpath = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Outputs\Set1_and_2_fixed\wind_per_wav.csv';
        %wind_per_wav_fullpath = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Outputs\HEROWEC_renamed_UTC_bkgnd_fixed\wind_per_wav.csv';
        wind_per_wav_fullpath = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Outputs\2025_06_23_bkgnd\wind_per_wav.csv';

    case 'OOI'
        % Specify hydrophone e.g. so we can lookup cal per hydrophone
        % For OOI, specify whether shelf or offshore (for ooi)
        % 'LJ01D' is shelf broad-band hydrophone
        % 'LJ01C' is offshore broad-band hydrophone
        hydrophone = 'LJ01D';

        % Specify wind/rain bin
        bin_wind_rain_str = 'wind10m_3mps_rainrte_0mmphr';

        % Specify folder for mat files
        PSD_matfile_folder = strcat('C:\Users\s44ba\Documents\Projects\from_JPA_moran\ooi\PSD\', bin_wind_rain_str,'\', hydrophone,'\');

        % Search string for *_PSD.mat files
        search_string = strcat(PSD_matfile_folder,'*PSD.mat');

    otherwise
        error('Unknown project');
end


%% Project-specific processing% Specify project-specific user input
switch project
    case 'CSI'
        % Get list of PSD matfiles for this bin (a subset of the files in
        % the single PSD_matfile_folder)
        dir_list = get_PSD_matfiles_per_bin(wind_speed_range, wind_dir_range, wind_per_wav_fullpath, PSD_matfile_folder);

    case 'OOI'
        % Get list of mat files (already stored in a folder per bin)
        dir_list = dir(search_string);
end        


%% Processing (same for all projects)
% Init
num_files = length(dir_list);

% Loop through files, loading
cwd = pwd;
cd(PSD_matfile_folder);
tot_num_rows = 0;
PSD_per_window_cal_all = [];
for file_num = 1:num_files
    x = load(dir_list(file_num).name);
    [num_rows,~] = size(x.PSD_per_window_cal);
    tot_num_rows = tot_num_rows + num_rows;
    PSD_per_window_cal_all = cat(1,PSD_per_window_cal_all,x.PSD_per_window_cal);
end

% Verify tot_num_rows
%tot_num_rows

% Calc stats on concatenated PSD
cd(cwd);
frequency_Hz = x.frequency_Hz;    % Assume all are same
LTAS_gen_PSD_stats(PSD_per_window_cal_all,frequency_Hz)

% Plot pdf of PSD at 1 frequency
freq_idx = 104; % For 512k samples/sec, 104 for 4k
% Slice PSD array at this freq
PSD_per_window_cal_all_sliced_dB = 10*log10(PSD_per_window_cal_all(:,freq_idx));
figure; histogram(PSD_per_window_cal_all_sliced_dB,'Normalization','pdf');
hist_obj = histogram(PSD_per_window_cal_all_sliced_dB,'Normalization','pdf');
bin_centers = hist_obj.BinEdges(1:end-1) + 0.5*diff(hist_obj.BinEdges);
figure; plot(bin_centers,hist_obj.Values,'bo-');





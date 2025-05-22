%% Doc
% This program concatenates the PSD mat files that belong to a specified
% wind-speed/wind-dir/rain-rate bin. You must run it for each bin.


%% User input
% Specify project CSI or OOI
project = 'CSI';

% Specify project-specific user input
switch project
    case 'CSI'
        % Specify wind speed range in m/s
        wind_speed_range = [2.0 4.0];

        % Specify wind dir range in degrees clockwaise from North (that
        % wind is coming FROM)
        wind_dir_range = [180 225];

        % Specify folder for PSD mat files
        PSD_matfile_folder = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Matfiles\';

        % Specify fullpath to wind_per_wav.csv
        wind_per_wav_fullpath = "C:\Users\s44ba\Documents\Projects\JeanettesPier\Outputs\wind_per_wav.csv";

    case 'OOI'
        % Specify hydrophone e.g. so we can lookup cal per hydrophone
        % For OOI, specify whether shelf or offshore (for ooi)
        % 'LJ01D' is shelf broad-band hydrophone
        % 'LJ01C' is offshore broad-band hydrophone
        hydrophone = 'LJ01D';

        % Specify wind/rain bin
        bin_wind_rain_str = 'wind10m_3mps_rainrte_3mmphr';

        % Specify folder for mat files
        PSD_matfile_folder = strcat('../PSD/', bin_wind_rain_str,'/', hydrophone,'/');

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




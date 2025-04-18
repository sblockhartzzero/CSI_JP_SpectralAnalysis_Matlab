%% Doc
% This program concatenates the PSD mat files that belong to a specified
% wind-speed/rain-rate bin. You must run it for each bin.

% So, e.g. for project = 'CSI', edit the bin_number and run, generating
% plots for the specified bin

%% User input
% Specify project CSI or OOI
project = 'CSI';

% Specify project-specific info
switch project
    case 'CSI'
        % Specify bin_number
        bin_number = 1;

        % Specify folder for mat files
        matfile_folder = 'C:\Users\s44ba\Documents\Projects\JeanettesPier\Matfiles\';

        % Get list of PSD matfiles for this bin (a subset of the files in
        % the single matfile_folder)
        dir_list = get_PSD_matfiles_per_bin(bin_number, matfile_folder);

    case 'OOI'
        % Specify hydrophone e.g. so we can lookup cal per hydrophone
        % For OOI, specify whether shelf or offshore (for ooi)
        % 'LJ01D' is shelf broad-band hydrophone
        % 'LJ01C' is offshore broad-band hydrophone
        hydrophone = 'LJ01D';

        % Specify wind/rain bin
        bin_wind_rain_str = 'wind10m_3mps_rainrte_3mmphr';

        % Specify folder for mat files
        matfile_folder = strcat('../PSD/', bin_wind_rain_str,'/', hydrophone,'/');

        % Search string for *_PSD.mat files
        search_string = strcat(PSD_matfile_folder,'*PSD.mat');

        % Get list of mat files (already stored in a folder per bin)
        dir_list = dir(search_string);

    otherwise
        error('Unknown project');
end


%% Processing
% Init
num_files = length(dir_list);

% Loop through files, loading
cwd = pwd;
cd(matfile_folder);
tot_num_rows = 0;
PSD_per_window_cal_all = [];
for file_num = 1:num_files
    x = load(dir_list(file_num).name);
    [num_rows,~] = size(x.PSD_per_window_cal);
    tot_num_rows = tot_num_rows + num_rows;
    PSD_per_window_cal_all = cat(1,PSD_per_window_cal_all,x.PSD_per_window_cal);
end

% Verify tot_num_rows
tot_num_rows

% Calc stats on concatenated PSD
cd(cwd);
frequency_Hz = x.frequency_Hz;    % Assume all are same
LTAS_gen_PSD_stats(PSD_per_window_cal_all,frequency_Hz)




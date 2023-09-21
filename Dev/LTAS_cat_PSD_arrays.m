%% User input
% Specify hydrophone e.g. so we can lookup cal per hydrophone
% For OOI, specify whether shelf or offshore (for ooi)
% 'LJ01D' is shelf broad-band hydrophone
% 'LJ01C' is offshore broad-band hydrophone
hydrophone = 'LJ01D';

% Specify wind/rain bin
bin_wind_rain_str = 'wind10m_3mps_rainrte_3mmphr';

% Specify folder for mat files to be concatenated together
PSD_matfile_folder = strcat('../PSD/', bin_wind_rain_str,'/', hydrophone,'/');


%% Processing
% Get list of mat files
search_string = strcat(PSD_matfile_folder,'*PSD.mat');
dir_list = dir(search_string);
num_files = length(dir_list);

% Loop through files, loading
cwd = pwd;
cd(PSD_matfile_folder);
tot_num_rows = 0;
PSD_per_window_cal_all = [];
for file_num = 1:num_files
    x(file_num) = load(dir_list(file_num).name);
    [num_rows,~] = size(x(file_num).PSD_per_window_cal);
    tot_num_rows = tot_num_rows + num_rows;
    PSD_per_window_cal_all = cat(1,PSD_per_window_cal_all,x(file_num).PSD_per_window_cal);
end

% Verify tot_num_rows
tot_num_rows

% Calc stats on concatenated PSD
cd(cwd);
frequency_Hz = x(file_num).frequency_Hz;    % Assume all are same
LTAS_gen_PSD_stats(PSD_per_window_cal_all,frequency_Hz)




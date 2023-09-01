%% User input
% Specify folder for mat files to be concatenated togerher
PSD_matfile_folder = 'C:\Users\SteveLockhart\github\CSI_JP_SpectralAnalysis_Matlab\Output\Test\';


%% Processing
% Get list of mat files
search_string = strcat(PSD_matfile_folder,'*PSD.mat');
dir_list = dir(search_string);
num_files = length(dir_list);

% Loop through files, loading
cwd = pwd;
cd(PSD_matfile_folder);
tot_num_rows = 0;
PSD_per_window_all = [];
for file_num = 1:num_files
    x(file_num) = load(dir_list(file_num).name);
    [num_rows,~] = size(x(file_num).PSD_per_window);
    tot_num_rows = tot_num_rows + num_rows;
    PSD_per_window_all = cat(1,PSD_per_window_all,x(file_num).PSD_per_window);
end

% Verify tot_num_rows
tot_num_rows

% Calc stats on concatenated PSD
cd(cwd);
LTAS_gen_PSD_stats(PSD_per_window_all,frequency_Hz)




function dir_list = get_PSD_matfiles_per_bin(wind_speed_range, wind_dir_range, wind_per_wav_fullpath, matfile_folder)

% Load the wind_per_wav.csv from wind_per_wav_fullpath
% to see which *_PSD mat files are in this wind_speed_range.
% This loads wind_per_wav_fullpath like
%{
wav_filename_sans_ext,wind_speed,wind_dir
SCW1984_20210421_132000,2.25129502121495,186.33333333333334
SCW1984_20210421_142000,6.1,160.1
SCW1984_20210423_134500,2.6265108580841083,124.0
%}
A=readtable(wind_per_wav_fullpath,'VariableNamingRule','preserve');

% Unpack 
wav_filename_sans_ext_array = table2array(A(:,1));
wind_speed_array = table2array(A(:,2));
wind_dir_array = table2array(A(:,3));

% Subset, where wind_speed is in range
wind_speed_array_idx = find( ( (wind_speed_array>=wind_speed_range(1)) & (wind_speed_array<wind_speed_range(2)) ) & ...
                             ( (wind_dir_array>=wind_dir_range(1)) & (wind_dir_array<wind_dir_range(2)) ) );
wav_filename_sans_ext_array_subsetted = wav_filename_sans_ext_array(wind_speed_array_idx);
num_wav_files_subsetted = length(wav_filename_sans_ext_array_subsetted);


% Populate output struct dir_list
% Init
dir_list = struct;
% Loop on files
for k=1:num_wav_files_subsetted
    PSD_mat_filename = strcat(wav_filename_sans_ext_array_subsetted{k},'_PSD.mat');
    dir_list(k).name = PSD_mat_filename;
    dir_list(k).folder = matfile_folder;
end
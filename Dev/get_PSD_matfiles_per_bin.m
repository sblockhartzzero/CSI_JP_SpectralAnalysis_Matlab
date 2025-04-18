function dir_list = get_PSD_matfiles_per_bin(bin_number, matfile_folder)

% Load the wav_files_per_bin.mat from the matfile_folder
% to see which *_PSD mat files are in this bin_number.
% This loads the struct ws_rr_bin like
%{
ws_rr_bin = 
  struct with fields:
    wav_filename_sans_ext_array: {'SCW1984_20210421_132000'  'xyz'}
                       ws_range: [0 3]
                       rr_range: [0 5]
%}
matfilename = strcat(matfile_folder,'wav_files_per_bin.mat')
load(matfilename);

% Unpack the wav_filename_sans_ext_array
wav_filename_sans_ext_array = ws_rr_bin(bin_number).wav_filename_sans_ext_array;
num_wav_files = length(wav_filename_sans_ext_array);

% Populate output struct dir_list
% Init
dir_list = struct
% Loop on files
for wav_file_num=1:num_wav_files
    PSD_mat_filename = strcat(wav_filename_sans_ext_array{wav_file_num},'_PSD.mat')
    dir_list(wav_file_num).name = PSD_mat_filename;
    dir_list(wav_file_num).folder = matfile_folder;
end
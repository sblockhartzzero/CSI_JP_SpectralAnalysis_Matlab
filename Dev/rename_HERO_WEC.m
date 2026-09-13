%% User input
deployment_type = 'Impact';
switch deployment_type
    case 'Impact'
        % Specify input dir (wav files to be renamed)
        input_dir = 'F:\JeannetesPier\data\field measurements + environmental conditions\acoustic impact\2024_03_14_HEROWEC_Deployment\03-14-2024_WEC_Deployment\';

        % Specify output_dir (for renamed files)
        output_dir = 'F:\JeannetesPier\data\field measurements + environmental conditions\acoustic impact\2024_03_14_HEROWEC_Deployment_Renamed_UTC\impact\';

        % Specify start timestamp for first file, adding 4 hrs for UTC
        start_deployment_datenum = datenum("2024-03-14T10:00:00",'yyyy-mm-ddTHH:MM:SS');
    case 'Background'
        % Specify input dir (wav files to be renamed)
        input_dir = 'F:\JeannetesPier\data\field measurements + environmental conditions\acoustic impact\2024_03_14_HEROWEC_Deployment\03-14-2024_WEC_Deployment_ Background\';

        % Specify output_dir (for renamed files)
        output_dir = 'F:\JeannetesPier\data\field measurements + environmental conditions\acoustic impact\2024_03_14_HEROWEC_Deployment_Renamed_UTC\background\';

        % Specify start timestamp for first file, adding 4 hrs for UTC
        start_deployment_datenum = datenum("2024-03-14T16:00:00",'yyyy-mm-ddTHH:MM:SS');
    otherwise
        error('Unknown deployment type');
end


%% Constants
secs_per_day = 3600*24;


%% Processing
% Get list of wav files for this deployment
search_string = strcat(input_dir,'*.wav');
dir_list = dir(search_string);
num_files = length(dir_list);

% Init
offset_secs = 0;
% Loop on files, deriving filename from file start timestamp
for file_num = 1:num_files
    % Get wave filename, fullpath
    wav_filename = dir_list(file_num).name;
    wavfile_fullpath = strcat(input_dir, wav_filename);

    % Derive new filename from timestamp 
    % e.g. HEROWECb_20210421_132000.wav or HEROWECi_20210421_132000.wav
    this_wav_start_datenum = start_deployment_datenum + (offset_secs/secs_per_day);     % unit of datenum is days (since some reference)
    this_datestr = datestr(this_wav_start_datenum,'yyyymmdd_HHMMSS')
    switch deployment_type
        case 'Impact'
            rename_fullpath = strcat(output_dir,'HEROWECi_',this_datestr,'.wav');
        case 'Background'
            rename_fullpath = strcat(output_dir,'HEROWECb_',this_datestr,'.wav');
        otherwise
            error('Unknown deployment type');
    end

    % Display
    fprintf("%s %s %s %s\n",'Renaming', wavfile_fullpath, 'to', rename_fullpath);
    copyfile(wavfile_fullpath,rename_fullpath)
    
    % Get info.Duration of this wav file to use for offset to next wav file
    info = audioinfo(wavfile_fullpath);
    offset_secs = offset_secs + info.Duration;
end


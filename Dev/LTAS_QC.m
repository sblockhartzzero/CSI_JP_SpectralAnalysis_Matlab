function [LTAS_QC_ind, reason] = LTAS_QC(y_segment, Fs, start_secs_in, wav_filename_sans_ext, QC_CFG)

%% Doc


%% Processing
% Constants
secs_per_day = 3600*24;

% Enable plotting of each QC issue
plot_flag = false;

% The default is that the segment is OK; i.e. no QC issue.
% Set output vars to defaults.
LTAS_QC_ind = true;
reason = '';

% Check for clipping
if (max(abs(y_segment))>0.98)
    LTAS_QC_ind = false;
    reason = 'Clipping';
end    

% Check for abrupt change of the mean, which could indicate missing or skipped data
y_detrended = detrend(y_segment);
[TF,S1,S2] = ischange(y_detrended,'Threshold', 64);     
num_abrupt_changes = sum(TF);
if num_abrupt_changes > 0
    LTAS_QC_ind = false;
    reason = 'Discontinuity';
    if plot_flag
        figure; plot(y_segment,'*'); hold on
            stairs(S1);
            legend('Data','Segment Mean','Location','NW');
    end
end

% Check to see if there are tonals in this window
if QC_CFG.skip_tonals
    % See if there is a tonal that either starts or ends in this window.
    % First get end_datenum for this window. (We already have
    % segment_start_datenum.)
    segment_duration_secs = length(y_segment)/Fs;                                           % samples/(samples/sec) = sec
    %{
    segment_end_datenum = segment_start_datenum + (segment_duration_secs/secs_per_day);     % datenum has units of days since a reference
    % Question 1: Are there any tonals that start in this window (i.e. in
    % this segment)?
    tonal_start_Datenum = QC_CFG.tonals.event_Whistle_AllSets.start_Datenum;
    q1 = ( (tonal_start_Datenum>=segment_start_datenum) & (tonal_start_Datenum<segment_end_datenum) );
    if (sum(q1)>0)
        LTAS_QC_ind = false;
        reason = 'Tonal(s)';
        fprintf("%s tonals start in this window\n",num2str(sum(q1)));
    end
    % 
    % Question 2: Are there any tonals that end in this window (i.e. in
    % this segment)?
    tonal_end_Datenum = QC_CFG.tonals.event_Whistle_AllSets.stop_Datenum;
    q2 = ( (tonal_end_Datenum>=segment_start_datenum) & (tonal_end_Datenum<segment_end_datenum) );
    if (sum(q2)>0)
        LTAS_QC_ind = false;
        reason = 'Tonal(s)';
        fprintf("%s tonals end in this window\n",num2str(sum(q2)));
    end
    %}
    %
    % New method, using raven selections
    % Derive end_secs_in
    end_secs_in = start_secs_in + segment_duration_secs;
    % Build selection_fullpath  
    selection_fullpath = strcat(QC_CFG.selection_folder_tonals,'selections_WHISTLE_',wav_filename_sans_ext,'.selections.txt');
    % Call selections_in_window to get a count of the number of selections
    % that either start (q1) or end (q2) in this window
    [q1,q2] = selections_in_window(selection_fullpath, start_secs_in, end_secs_in);
    if q1>0
        LTAS_QC_ind = false;
        reason = 'Tonal(s)';
        fprintf("%s tonals start in this window\n",num2str(q1));
    end
    if q2>0
        LTAS_QC_ind = false;
        reason = 'Tonal(s)';
        fprintf("%s tonals end in this window\n",num2str(q2));
    end
end


% Temporary
%LTAS_QC_ind = true;


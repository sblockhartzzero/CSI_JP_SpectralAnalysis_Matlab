function [LTAS_QC_ind, reason] = LTAS_QC(y_segment, Fs, segment_start_datenum, QC_CFG)

%% Doc
%{
QC_CFG.tonals.event_Whistle_AllSets

ans = 

  struct with fields:

          start_Datenum: [7.3827e+05 7.3827e+05 7.3827e+05 7.3827e+05 7.3827e+05 7.3827e+05 7.3827e+05 7.3827e+05 … ] (1×129 double)
           stop_Datenum: [7.3827e+05 7.3827e+05 7.3827e+05 7.3827e+05 7.3827e+05 7.3827e+05 7.3827e+05 7.3827e+05 … ] (1×129 double)
               f_Hz_Min: [2125 2125 2125 2125 2125 2125 13375 12500 16125 2125 2250 2125 3625 2125 15125 2125 2125 7375 … ] (1×129 double)
               f_Hz_Max: [2500 2875 2750 2375 2500 2875 14125 12750 17250 2875 5125 3375 4750 3000 15250 3000 2750 … ] (1×129 double)
            f_Hz_Median: [2250 2250 2250 2250 2250 2250 13375 12625 17125 2250 3875 2500 3750 2625 15125 2500 2500 9750 … ] (1×129 double)
    snr_Power_dB_Median: [18.5511 18.5275 16.0827 16.8343 16.7805 18.5833 15.7159 15.5863 15.7918 17.0457 17.8183 … ] (1×129 double)
%}


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
%datestr(segment_start_datenum, 'mmmm dd, yyyy HH:MM:SS.FFF')
if QC_CFG.skip_tonals
    % See if there is a tonal that either starts or ends in this window.
    % First get end_datenum for this window. (We already have
    % segment_start_datenum.)
    segment_duration_secs = length(y_segment)/Fs;                                           % samples/(samples/sec) = sec
    segment_end_datenum = segment_start_datenum + (segment_duration_secs/secs_per_day);     % datenum has units of days since a reference
    % Question 1: Are there any tonals that start in this window (i.e. in
    % this segment)?
    tonal_start_Datenum = QC_CFG.tonals.event_Whistle_AllSets.start_Datenum;
    q1 = ( (tonal_start_Datenum>=segment_start_datenum) & (tonal_start_Datenum<segment_end_datenum) );
    if (sum(q1)>0)
        LTAS_QC_ind = false;
        reason = 'Tonal(s)';
    end
    % 
    % Question 2: Are there any tonals that end in this window (i.e. in
    % this segment)?
    tonal_end_Datenum = QC_CFG.tonals.event_Whistle_AllSets.stop_Datenum;
    q2 = ( (tonal_end_Datenum>=segment_start_datenum) & (tonal_end_Datenum<segment_end_datenum) );
    if (sum(q2)>0)
        LTAS_QC_ind = false;
        reason = 'Tonal(s)';
    end
end


% Temporary
%LTAS_QC_ind = true;


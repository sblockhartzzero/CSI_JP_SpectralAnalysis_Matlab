function [q1,q2] = selections_in_window(selection_fullpath, start_secs, end_secs)

% Find the number of selections between start_secs, end_secs
% where start_secs, end_secs referenced to start of wav file
% q1 = the number of selections that START in the window (from start_secs to end_secs)
% q2 = the number of selections that END in the window (from start_secs to end_secs)

% Default
num_selections = 0;

% Load time_offset_secs, freq_range_Hz for this selection_fullpath;
[time_offset_secs, freq_range_Hz] = xlat_raven_selections(selection_fullpath);

% Find rows that are in this window (between start_secs, end_secs)
% i.e. one of the following is true:
% EITHER    time_offset_secs(:,1) is between start_secs, end_secs OR
%           time_offset_secs(:,2) is between start_secs, end_secs
q1_idx = ( (time_offset_secs(:,1)>=start_secs) & (time_offset_secs(:,1)<end_secs) );
q2_idx = ( (time_offset_secs(:,2)>=start_secs) & (time_offset_secs(:,2)<end_secs) );
% Convert to counts
q1 = sum(q1_idx);
q2 = sum(q2_idx);
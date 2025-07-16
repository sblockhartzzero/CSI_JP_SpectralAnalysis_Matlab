function [q1,q2,q3] = selections_in_window(selection_fullpath, window_start_secs, window_end_secs)

% Find the number of selections that either start or stop in this window i.e. between window_start_secs and window_end_secs
% where window_start_secs, window_end_secs are referenced to the start of this wav file
% q1 = the number of selections that START in the window (from window_start_secs to window_end_secs)
% q2 = the number of selections that END in the window (from window_start_secs to window_end_secs)

% Also, test for another possibility--that this window is completely inside a detection event
% q3 =  the number of selections that START before this window (i.e. before window_start_secs) AND
%                                     END after this window (i.e. after window_end_secs)

% Load selection_offset_secs, freq_range_Hz for this selection_fullpath
% The detected events for this wav file are from selection_offset_secs(:,1) to time_offset_secs(:,2)
[selection_offset_secs, freq_range_Hz] = xlat_raven_selections(selection_fullpath);

% Find selections that are in this window (between window_start_secs, window_end_secs)
% i.e. one of the following is true:
% EITHER    selection_offset_secs(:,1) is between window_start_secs, window_end_secs OR
%           selection_offset_secs(:,2) is between window_start_secs, window_end_secs
q1_idx = ( (selection_offset_secs(:,1)>=window_start_secs) & (selection_offset_secs(:,1)<window_end_secs) );
q2_idx = ( (selection_offset_secs(:,2)>=window_start_secs) & (selection_offset_secs(:,2)<window_end_secs) );

% Is this window contained inside a selection?
q3_idx = ( (selection_offset_secs(:,1)<window_start_secs) & (selection_offset_secs(:,2)>window_end_secs));

% Convert to counts
q1 = sum(q1_idx);
q2 = sum(q2_idx);
q3 = sum(q3_idx);
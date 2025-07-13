function [time_offset_secs, freq_range_Hz] = xlat_raven_selections(selection_fullpath)

% Load selection file into table
A=readtable(selection_fullpath,'VariableNamingRule','preserve');

% Stuff into time_Offset_secs, which is the time in secs relative to the
% start of the wav file
time_offset_secs = [A.Var5 A.Var6];

% Stuff into freq_range_Hz
freq_range_Hz = [A.Var7 A.Var8];

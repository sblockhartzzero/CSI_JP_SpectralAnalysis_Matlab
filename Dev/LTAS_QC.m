function [LTAS_QC_ind, reason] = LTAS_QC(y_segment, Fs)

% Default is OK
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
    figure; plot(y_segment,'*'); hold on
            stairs(S1);
            legend('Data','Segment Mean','Location','NW')
end

% Temporary
%LTAS_QC_ind = true;


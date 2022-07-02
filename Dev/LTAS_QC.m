function LTAS_QC_ind = LTAS_QC(y_segment)

% Defaul is OK
LTAS_QC_ind = true;

% Make sure segment is detrended
y_detrended = detrend(y_segment);

% Check for abrupt change of the mean, which could indicate missing or skipped data
[TF,S1,S2] = ischange(y_detrended,'Threshold',64);
num_abrupt_changes = sum(TF);
if num_abrupt_changes > 0
    LTAS_QC_ind = false;
    figure; stairs(S1);
end

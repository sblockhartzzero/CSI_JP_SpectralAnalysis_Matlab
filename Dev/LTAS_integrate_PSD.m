function S = LTAS_integrate_PSD(PSD,frequency_Hz,freqrange)

% Index of frequency values in range
idx = ( (frequency_Hz>=freqrange(1)) & (frequency_Hz<=freqrange(2)) );

% Calculate integral
f_res = median(diff(frequency_Hz));
S = f_res*sum(PSD(idx));


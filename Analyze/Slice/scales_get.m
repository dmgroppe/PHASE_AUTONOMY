function [scales] = scales_get(ap, srate)

% Return the scales for performing wavelet transforms

if strcmp(ap.wt.scale, 'log')
    scales = log_scale(ap.wt.ostart, ap.wt.noctaves, ap.wt.nvoices);
else
    scales = linear_scale(ap.wt.freqs, srate);
end
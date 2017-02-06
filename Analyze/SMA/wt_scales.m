function [scales, freqs] = wt_scales(ap)

% return the scales for wavelet transform

if strcmpi(ap.wt.scale, 'log')
    scales = log_scale(ap.wt.ostart, ap.wt.noctaves, ap.wt.nvoices);
else
    scales = linear_scale(ap.wt.freqs, srate);
end

freqs = scal2frq(scales, sprintf('cmor%d-1',ap.wt.wnumber), 1/ap.srate);


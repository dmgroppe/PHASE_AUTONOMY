function [faxis fend] = faxis_truncate(w, ap)

% Truncates the frequency axis depending on oversampling

faxis = w(find(w <= ap.srate/ap.over_sample));
fend = length(faxis);
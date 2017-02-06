function [filt] = filter_t(x, frange, srate)

% Filters a matrix of time series.  It is assumed that the each row is a
% different time series

n_ts = size(x,1);
d = window_FIR(frange(1), frange(2), srate);
N = d.Numerator;

parfor i=1:n_ts
    filt(i,:) = filtfilt(N,1,x(i,:));
end
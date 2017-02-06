function [amp tintervals] = sync_pfc(ts, srate, frange)

d = window_FIR(frange(1), frange(2), srate);
x = filtfilt(d.Numerator,1,ts);

maxims = local_max(x);
maxims = maxims(2:end-1);
t = (0:length(x)-1)/srate;

% Get the previous amplitude and the following interval
for i=1:length(maxims)-1
    ie = maxims(i):maxims(i+1);
    amp(i) = x(ie(1))- min(x(ie));
    intervals(i) = ie(end)-ie(1);
end

tintervals = intervals/srate*1000;


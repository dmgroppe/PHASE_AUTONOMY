function [h] = get_hilberts(EEG, ch, cond, length, frange)

[tstart tend] = get_trange(cond, length);

subr = get_subregion(EEG, tstart, tend);

nchan = max(size(ch));
npoints = max(size(subr));

h = zeros(nchan, npoints);
for i=1:nchan
    h(i,:) = hilbert(eegfilt(double(subr(ch(i),:)), EEG.srate, frange(1), frange(2)));
end

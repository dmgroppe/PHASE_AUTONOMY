function [sync,uchannels] = sync_pairs(EEG, c_pairs, frange, tstart, tend, ap)
% Computes the sync matrix for a list of channel pairs

uchannels = uchan_from_pairs(c_pairs);
nuchan = length(uchannels);
if isempty(uchannels)
    display('Empty channel list.');
    return;
end

% Make the filter
d = window_FIR(frange(1), frange(2), EEG.srate);

for i=1:length(uchannels)
    x = EEG.data(uchannels(i), tstart:tend);
    if ap.surr
        % rotate the data set to generate surrogate time series
        x = rand_rotate(x);
    end
    h(:,i) = hilbert(filtfilt(d.Numerator,1,x));
end

fh = sync_fh(ap.atype);
sync = zeros(nuchan,nuchan);

for i=1:nuchan
    hi = h(:,i);
    parfor j=i+1:nuchan
        sync(j,i) = fh(hi, h(:,j));
    end
end
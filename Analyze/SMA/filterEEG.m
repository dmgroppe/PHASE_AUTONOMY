function [filtEEG] = filterEEG(EEG, newrate, locut, highcut, chtoexcl)

if nargin < 5; chtoexcl = []; end

[nchan npoints] = size(EEG.data);

new_npoints = npoints/(EEG.srate/newrate);
delta = floor(EEG.srate/newrate);

srate = EEG.srate;
ts = EEG.data;

fEEG = zeros(nchan, new_npoints);

if ~isempty(chtoexcl)
    fEEG(chtoexcl, :) = EEG.data(chtoexcl,1:delta:end);
end

parfor i=1:nchan
    if isempty(find(i==chtoexcl, 1))
        fEEG(i,:) = filter_resample(double(ts(i,:)), srate, newrate, locut, highcut);
    end
end

filtEEG = EEG;
filtEEG.srate = newrate;
filtEEG.data = zeros(nchan, new_npoints);
filtEEG.data = fEEG;
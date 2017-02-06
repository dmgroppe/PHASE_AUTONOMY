%USAGE: [cf_eeg] = commonref(EEG, chtoexclude)

function [cf_eeg] = commonref(EEG, chtoexclude)

[nchan npoints] = size(EEG.data);

if isempty(chtoexclude)
    dmean = mean(EEG.data);
else
    inc_chan = setxor(1:nchan,chtoexclude);
    dmean = mean(EEG.data(inc_chan,:));
end
    
cf_eeg = EEG;
cf_eeg.data = zeros(nchan, npoints);

for i=1:nchan
    if (isempty(find(chtoexclude == i, 1)))
        cf_eeg.data(i,:) = EEG.data(i,:) - dmean;
    else
        cf_eeg.data(i,:) = EEG.data(i,:);
    end
end
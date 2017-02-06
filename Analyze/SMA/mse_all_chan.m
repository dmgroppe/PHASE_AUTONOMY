function [SE] = mse_all_chan(EEG, frange)

nchan = size(EEG.data,1);

parfor i=1:nchan
    fprintf('Working on channel %d...', i);
    SE(i,:,:) = mse_eeg(EEG,i,frange);
end


function [wt channels] = wt_EEG(EEG, chtoexcl, freqs, wnumber)

channels = 1:size(EEG.data,1);
channels(chtoexcl) = [];

srate = EEG.srate;
for i=1:length(channels);
    wt(:,:,i) = twt(EEG.data(channels(i),:),srate, linear_scale(freqs,srate), wnumber);
end
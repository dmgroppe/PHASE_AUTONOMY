function [ch_std ch_mean] = EEG_stats(EEG)

[nchan ~] = size(EEG.data);
ch_std = std(EEG.data,1,2);
ch_mean = mean(EEG.data,2);

chans = 1:nchan;

figure(2);
clf;
subplot(2,1,1);
plot(chans, ch_mean);
xlabel('Channel number');
ylabel('Mean');
subplot(2,1,2);
plot(chans,ch_std);
xlabel('Channel number');
ylabel('Standard deviation');
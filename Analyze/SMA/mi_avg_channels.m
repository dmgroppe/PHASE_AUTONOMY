function [] = mi_avg_channels(EEG, cond, channels, lowfs, highfs)

nbin = 18;
nchan = size(EEG.data,1);

[tstart tend] = get_trange(cond, 60);
band_pass = window_highpass(2, EEG.srate);

count = 0;
for i=1:nchan
    if (~isempty(find(channels == i)))
        count = count+1;
        fprintf('Working on channel %d\n', i);
        x = get_ch_subregion(EEG, i, tstart, tend);
        x = filtfilt(band_pass.Numerator, 1, x);
        MI(:,:,count) = mod_index_compute(x, EEG.srate, lowfs, highfs, nbin, 10, 1);
        mnorm(x, EEG.srate, [4,8], [80 150]);
    end
end

meanMI = squeeze(mean(MI,3));
figure(1);
surf(lowfs, highfs, meanMI);
axis([lowfs(1), lowfs(end),highfs(1),highfs(end), min(min(meanMI)), max(max(meanMI))]);
shading interp;
view(0,90);
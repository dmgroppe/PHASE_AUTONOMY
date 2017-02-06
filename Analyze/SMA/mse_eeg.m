function [SE] = mse_eeg(EEG, ch, frange)

eDir = get_export_path_SMA();
%window = 500;
p = mse_params();

what = p.what;
condlist = p.condlist;
slength = p.slength;
ptname = p.ptname;
sim = p.sim;
simfreq = p.simfreq;

d = window_FIR(frange(1), frange(2), EEG.srate);
Num = d.Numerator;
tic

if p.sim
    ncond = 1;
else
    ncond = numel(p.condlist);
end

parfor i=1:ncond
    [tstart tend] = get_trange(condlist{i}, slength, ptname);
    subr = get_subregion(EEG, tstart, tend);
    subr = squeeze(subr(ch,:));
    if sim
        subr = sin_wave(simfreq, length(subr), EEG.srate, 0) + ...
            (0.5-rand(1,length(subr)))*0.1;
    end
    switch what
        case 'raw'
            x = subr;
        case 'env'
            x = abs(hilbert(filtfilt(Num,1,subr)));
        case 'filt'
            x = filtfilt(Num,1,subr);
    end
    se = mse(x, p);
    SE(i,:) = se(1,:,1);
end
toc

h = figure(1);

text = sprintf('Channel %d, %s (%4.0f to %4.0f)', ch, what, frange(1), frange(2));
set(h, 'Name', ['MSE - ' text]);

plot(SE');
xlabel('scale');
ylabel('SE');
legend(p.condlist,'Location', 'Best');
title(text);

%error = rmse(SE');
%fprintf('RMS error = %6.4f\n', error);

save_figure(h, get_export_path_SMA(), ['MSE - ' text])


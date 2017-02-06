function [] = ps_corr_mchan(EEG, cond, ptname, chan, dosave)

if nargin < 5; dosave = 0; end;

parfor i=1:length(chan)
    [rho(:,:,i), w(:,i)] = ps_freq_corr(EEG, cond, 60, chan(i), ptname, 500, 0, 0);
end

mrho = mean(rho,3);
srho = std(rho,1, 3);
zrho = mrho./srho;

trho = zrho;

% Threshold to p = 0.05
trho(zrho < 1.959964) = 0;

text = sprintf('Power-corr %s %s', upper(ptname), upper(cond));
h = figure(1);
clf('reset');
set(h, 'Name', text);
plot_rho(w(:,1),trho);
text = sprintf('Power-corr %s %s', upper(ptname), upper(cond));
title(text);
caxis([0 3]);

if dosave
    save_figure(h, get_export_path_SMA(), text);
end
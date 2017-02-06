function [] = sync_pfc_noise()

amp = 30;
frange = [60 200];
srate = 1000;

[amps, ints] = sync_pfc(amp*(rand(1,60000)-0.5), srate, frange);

h = figure(1);
fname = 'Noise Power frequency correlation';
set(h, 'Name', fname);
sync_pfc_plot(amps, ints, [0 30], [0 25]);
title('Noise');

[rho, p] = corr(amps',ints','type','Spearman');
ltext = sprintf('R = %4.2f, p = %4.2e', rho,p);
legend(ltext);
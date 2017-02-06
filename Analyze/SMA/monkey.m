function [] = monkey(ch, frange, revrel, dosave)

if nargin < 3; revrel = 0; end;
if nargin < 4; dosave = 0; end;

fname = 'D:\Projects\Data\Monkey\Sample-LFPs.mat';
load(fname);
srate = 500;

[amps tintervals] = sync_pfc(ad{ch}, srate, frange);

% Reverse the relationship
if revrel
    intervals = intervals(2:end);
    amps = amps(1:end-1);
end

h = figure(1);
fname = 'Monkey Power frequency correlation';
set(h, 'Name', fname);
sync_pfc_plot(amps, tintervals, [0 100], [0 15]);
title('Monkey LFP');

[rho, p] = corr(amps',tintervals','type','Spearman');
ltext = sprintf('R = %4.2f, p = %4.2e', rho,p);
legend(ltext);

if dosave
    save_figure(h, get_export_path_SMA(), fname);
end
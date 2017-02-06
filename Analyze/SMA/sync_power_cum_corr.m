function [] = sync_power_cum_corr(EEG, ap, pairs)

% Collates all the sync-power relationships for 'pairs' and computes grand
% power-sync correlations
% By my terminology this is "between channel PC dependant power correlation
% "

npairs = length(pairs);

frange = ap.frange;
cond = ap.condlist{1};
dlength = ap.length;
ptname = ap.ptname;
atype = ap.atype;
window = ap.window;

fprintf('\nComputing sync-power depenance for %d pairs.\n', npairs);
for i=1:npairs
    [R{i}, sync(:,i), amps(:,:,i),ampcorr(:,i)] = sync_power(EEG, pairs(:,i), frange,...
        cond, dlength, ptname, atype, window, 0);
end


% Plot all the corr-sync pairs

h = figure(1);
fname = sprintf('%s %s %s Cumulative sync stats', upper(ptname), upper(cond),...
    upper(atype));
set(h, 'Name', fname);

all_syncs = reshape(sync, min(size(sync))*max(size(sync)), 1);
all_corrs=reshape(ampcorr, min(size(ampcorr))*max(size(ampcorr)), 1);

corr_plot(all_syncs', all_corrs', 'scatter');
set(0,'RecursionLimit',length(all_syncs)*2);
[rho, pval] = corr(all_syncs,all_corrs,'type','Spearman');
legend(sprintf('R = %6.4f, p = %6.4f', rho, pval));
axis square;
title(fname);

if isempty(ap.yaxis)
    axis([0 1 0 1]);
else
    axis([0 1 ap.yaxis]);
end

save_figure(h, get_export_path_SMA(), fname);








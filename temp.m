%%
h2 = figure(2); clf;
set(h2, 'Name', sprintf('Szprec_page_hinkley summary: %s', sz_name));
subplot(2,2,1);
barh(1:length(A_sorted), A_sorted);
axis([xlim 1 length(A_sorted)+1]);
set(gca, 'YDir', 'reverse', 'TickDir', 'out');
set(gca, 'YTick', 1:numel(A_sorted));
set(gca, 'YTickLabel', ch_labels(ind_A), 'FontSize', 4,'FontName','Small fonts');
xlabel('Amplitude of change (units)', 'FontSize', 6);
title('Amplitude of changes');


%% PLot the correlation of times and amplitudes
subplot(2,2,2);
corr_loc = loc_sorted;
excl = find(loc_sorted == npoints);
corr_loc(excl) = [];
A_ind = ind;
A_ind(excl) = [];

plot(t(corr_loc), loc_A(A_ind), '.', 'LineStyle', 'none', 'MarkerSize', 10);
xlabel('Time of change(s)');
ylabel('Amplitude of change');

if ~isempty(corr_loc) && ~isempty(A_ind)
    [rho, p] = corr(t(corr_loc)', loc_A(A_ind)', 'type', 'Spearman');
    title(sprintf('r = %6.2f, p = %6.4f', rho, p));
end


%% Plot without sorting the timing of changes
subplot(2,2,4);

p_loc = loc/srate-nanmedian(loc/srate);
ind = find(isnan(p_loc) == 0);
p_loc = (p_loc-nanmedian(p_loc))/iqr(p_loc(ind));

barh(1:length(loc), p_loc);
axis([xlim 0 length(loc)+1]);
set(gca, 'YDir', 'reverse', 'TickDir', 'out');
set(gca, 'YTick', 1:numel(loc));
set(gca, 'YTickLabel', ch_labels, 'FontSize', 4,'FontName','Small fonts');
xlabel('Time - mean time across channels', 'FontSize', 5);
title('Unranked time of change - mean across channels', 'FontSize', 6);


%% PLot the times of detected changes
subplot(2,2,3);
[tp, tp_ind] =  sort(p_loc);

barh(1:length(loc_sorted), tp);
axis([xlim 0 length(loc_sorted)+1]);
set(gca, 'YDir', 'reverse', 'TickDir', 'out');
set(gca, 'YTick', 1:numel(loc_sorted));
set(gca, 'YTickLabel', ch_labels(tp_ind), 'FontSize', 4,'FontName','Small fonts');
xlabel('Time of earliest stat sig change (s)', 'FontSize', 6);
title('Timing of changes');

% save all the stuff
if a_cfg.stats.use_max
    suf = '_max';
else
    suf = '_early';
end

fdir = fullfile(fpath,['Page-Hinkley' suf]);
if ~exist(fdir, 'dir')
    mkdir(fdir);
end

%%
fname = fullfile(fdir, [sz_name '-PH']);
R = struct_from_list('hp', hp, 'A', A, 'U', U, 'pval', pval,...
    'loc', loc, 'loc_pval', loc_pval, 'loc_A', loc_A, 'a_cfg', a_cfg,...
    'all_surr_A', all_surr_A, 'srate', srate);

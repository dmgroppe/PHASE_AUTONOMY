function [R] = Szprec_ph_replot(sz_name, suff)

global DATA_PATH;

cfg = cfg_default();
suf = ['_' suff];

pt_name = strtok(sz_name, '_');
fpath = make_file_name(DATA_PATH, sz_name, 'Adaptive deriv', '_F');
fdir = fullfile(fpath,['Page-Hinkley' suf]);
fname = fullfile(fdir, [sz_name '-PH.mat']);

if exist(fname, 'file');
    load(fname);
else
    display(fname);
    display('File not found.')
    return;
end

% PLot all the stuff
[ch_labels, ~] = get_channels_with_text(pt_name, [], 'bipolar');

% ind
% ch_list
% ch_labels(ind_A)


% h2 = figure(2); clf;
% set(h2, 'Name', sprintf('Szprec_page_hinkley summary: %s', sz_name));
% subplot(2,2,1);
% barh(1:length(A_sorted), A_sorted);
% axis([xlim 1 length(A_sorted)+1]);
% set(gca, 'YDir', 'reverse', 'TickDir', 'out');
% set(gca, 'YTick', 1:numel(A_sorted));
% set(gca, 'YTickLabel', ch_labels(ind_A), 'FontSize', 4,'FontName','Small fonts');
% xlabel('Amplitude of change (units)', 'FontSize', 6);
% title('Amplitude of changes');


% % PLot the correlation of times and amplitudes
% subplot(2,2,2);
% corr_loc = loc_sorted;
% excl = find(loc_sorted == npoints);
% corr_loc(excl) = [];
% A_ind = ind;
% A_ind(excl) = [];
% 
% plot(t(corr_loc), loc_A(A_ind), '.', 'LineStyle', 'none', 'MarkerSize', 10);
% xlabel('Time of change(s)');
% ylabel('Amplitude of change');
% 
% if ~isempty(corr_loc) && ~isempty(A_ind)
%     [rho, p] = corr(t(corr_loc)', loc_A(A_ind)', 'type', 'Spearman');
%     title(sprintf('r = %6.2f, p = %6.4f', rho, p));
% end

% Plot without sorting the timing of changes
subplot(1,2,1);

loc = R.loc;
srate = R.srate;

[loc_sorted, ind] = sort(loc,'ascend');

p_loc = R.loc/R.srate-nanmedian(R.loc/srate);
ind = find(isnan(p_loc) == 0);
p_loc = (p_loc-nanmedian(p_loc))/iqr(p_loc(ind));

barh(1:length(loc), p_loc);
axis([xlim 0 length(loc)+1]);
set(gca, 'YDir', 'reverse', 'TickDir', 'out');
set(gca, 'YTick', 1:numel(loc));
set(gca, 'YTickLabel', ch_labels, 'FontSize', 6,'FontName','Times');
xlabel('Time - mean time across channels', 'FontSize', 10);
title('Unranked time of change - mean across channels', 'FontSize', 10);

% PLot the times of detected changes
subplot(1,2,2);
[tp, tp_ind] =  sort(p_loc);

barh(1:length(loc_sorted), tp);
axis([xlim 0 length(loc_sorted)+1]);
set(gca, 'YDir', 'reverse', 'TickDir', 'out');
set(gca, 'YTick', 1:numel(loc_sorted));
set(gca, 'YTickLabel', ch_labels(tp_ind), 'FontSize', 6,'FontName','Times');
xlabel('Time of earliest stat sig change (s)', 'FontSize', 10);
title('Timing of changes');

%% Support functions
function [fname] = make_file_name(DATA_PATH, sz_name, folder, suffix)
pt_name = strtok(sz_name, '_');
fname = fullfile(DATA_PATH, 'Szprec',  pt_name, 'Processed', folder,...
        [sz_name suffix]);
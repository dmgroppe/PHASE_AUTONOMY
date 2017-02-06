function [] = plotAll(sz_name)

a_cfg = cfg_default();
pt_name = strtok(sz_name, '_');

display('Loading all the various data aspects...')
[~, F, D] = Szprec_load_all(sz_name,0);
if isempty(F) || isempty(D)
    display('Daat not loaded, exiting.');
end

[~,npoints, nchan] = size(F);
srate = D.Sf;

T = (0:(npoints-1))/srate;

nplots = 9;
cm = cbrewer('div', 'RdYlBu', 64);
cm = flipud(cm);


% Interesting here is whether to rank before or after the normalization.  I
% think it is likely better after, but I have typically ranked before. Need
% to explore this.
[rank, ~] = Szprec_rank1(F,a_cfg, a_cfg,pt_name);
%f = p_norm(fr);

a_cfg.stats.normalize = false;
a_cfg.stats.prec_weight = 'max'; 
f = fNorm(F, pt_name, a_cfg);
f = p_norm(f);


h = figure;
set(h, 'Name', sz_name);

% -------- Plot the RANKING
ax(1) = subplot (nplots,1, [1 2]);
colormap(cm);
imagesc(T,1:nchan, rank');
axis([T(1) T(end) -1 nchan+2 0 1]);
view(0,90);
caxis([0 1]);
set(ax(1), 'FontSize' , 7, 'TickDir', 'out', 'XTick',[]);

ax_p1 = re_label_yaxis(pt_name, a_cfg, T, nchan);

% ------------ Plot the normalized precursor values
% Plot F for each channel
ax(2) = subplot(nplots,1, [3 5]);

imagesc(T,1:nchan,f');
axis([T(1) T(end) -1 nchan+2 0 1]);
view(0,90)
caxis([0 1]);
set(ax(2), 'FontSize' , 7, 'TickDir', 'out', 'XTick',[]);
title('Normalized preecursor values', 'FontSize', 7);

ax_p2 = re_label_yaxis(pt_name, a_cfg, T, nchan);

% Plot the avererage of the F across all channels to see any global patterns

% ax(3) = subplot(nplots,1,5);
% gAvg = zscore(nanmean(f, 2));
% plot(T, smooth(gAvg,fix(srate/10)));
% axis([0 T(end) -3 max(gAvg)]);
% set(ax(3), 'FontSize' , 7, 'TickDir', 'out', 'XTick',[]);
% title('Average across all channels', 'FontSize', 7);
% ylabel('Z', 'FontSize', 7);

% PLot the data

ax(3) = subplot(nplots,1,[6 9]);
ax_p3 = Szprec_tf(D.matrix_bi, srate,a_cfg,pt_name);

ax = [ax ax_p1 ax_p2 ax_p3];

linkaxes(ax, 'xy');

















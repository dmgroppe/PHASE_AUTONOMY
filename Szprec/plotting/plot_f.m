function [] = plot_f(F,d,rank,srate,cfg,sdir,nplots)

% Rank the values
[npoints,nchan] = size(F);

clf;
T = (0:(npoints-1))/srate;

ax(1) = subplot(nplots,1,1);
imagesc(T,1:nchan, F');
set(gca, 'TickDir', 'out');
axis([T(1) T(end) 1 nchan zlim]);
view(0,90);
set(gca, 'FontSize', 7);
title('Precursor');
xlabel('Time (s)');
ylabel('Channel number');
ax_l1 = re_label_yaxis(sdir, cfg, T, nchan);


ax(2) = subplot (nplots,1,2);
imagesc(T,1:nchan, rank');
set(gca, 'TickDir', 'out');
axis([T(1) T(end) 1 nchan 0 1]);
view(0,90);
set(gca, 'FontSize' , 7);
xlabel('Time (s)');
ylabel('Channel number');
title('Rank', 'FontSize', 7);
ax_l2 = re_label_yaxis(sdir, cfg, T, nchan);

ax(3) = subplot(nplots,1,3);
Sprec_tf(d, srate, cfg)
ax_l3 = re_label_yaxis(sdir, cfg, T, nchan);
set(gca, 'FontSize', 5,'FontName','Small fonts');
%axes_text_style();

linkaxes([ax ax_l1 ax_l2 ax_l3], 'xy');

 

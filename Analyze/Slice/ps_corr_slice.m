function [] = ps_corr_slice(dDir,fn, S, p_range, window, save_fig)

h = figure(1);
nchan = size(S.data,1);
for i=1:nchan
    ax(i) = subplot(nchan,1,i);
    ps_corr(S.data(i,p_range():p_range(2)), S.srate, window, 0);
    title(sprintf('%s CH %d', fn, i));
end
linkaxes(ax, 'xy');


if save_fig
    save_figure(h, [dDir 'figures\'], fn);
end
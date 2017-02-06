function [ax] = plot2WithLabels(p1, d, srate, pt_name, nplots)

% Do two plots with relabelling of axes

if nargin < 5; nplots = 3; end;

[nchan npoints] = size(p1);
T = (0:(npoints-1))/srate;
cfg.chtype = 'bipolar';

clf;
ax = subplot(nplots,1,1);

imagesc(T,1:nchan, p1);
set(gca, 'FontSize' , 7);
set(gca, 'TickDir', 'out');
%colorbar;
xlabel('Time (s)');

ax_p1 = re_label_yaxis(pt_name, cfg, T, nchan);

subplot (nplots,1,2);
ax_p2 = Szprec_tf(d, srate, cfg_default(), pt_name);

ax = [ax ax_p1 ax_p2];
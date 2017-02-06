function [ax] = Szprec_tf(d, srate, cfg, sdir)

if nargin < 4; sdir = []; end;

[npoints nchan] = size(d);
d = remove_nans(d);
T = (0:(npoints-1))/srate; % Time in seconds

count = 0;
hold on;
set(gca, 'FontSize', 5,'FontName','Small fonts');
set(gca, 'YDir', 'reverse');
set(gca,'TickDir', 'out');

pindex = 1:nchan;
for i=nchan:-1:1
    count = count + 1;
    plot(T, -(d(:,pindex(i))-mean(d(:,pindex(i))))+i,'k');
end

axis([T(1) T(end) -1 nchan+2]);
hold off;
if ~isempty(sdir)
    ax = re_label_yaxis(sdir, cfg, T, nchan);
end
title(upper(cfg.chtype));
xlabel('Time(s)');
set(gca, 'TickDir', 'out');


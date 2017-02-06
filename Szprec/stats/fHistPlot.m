function [] = fHistPlot(f, xrange)

if nargin <2; xrange = [0 1]; end;

clf;
[~, nchan] = size(f);
[r,c] = rc_plot(nchan);
h = tight_subplot(r,c,0.04,[0.01 0.02],0.01);

% nf = p_norm(f);
nf = f;

for i=1:nchan
    axes(h(i));
    hist(nf(:,i),100);
    set(gca,'FontSize', 5, 'TickDir', 'out', 'box', 'off');
    axis([xrange ylim])
    title(sprintf('ch%d',i), 'FontSize', 5);
end
    
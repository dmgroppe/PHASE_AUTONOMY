function [] = plot_pf(z, freqs, i, cx)

% Function to plot pfcorr results.  Should pass it z-corred correlations
% and 2 columns (pre, onset values), and length nfreqs

if nargin < 4; cx = [-1 1]; end;

nfreq = length(freqs);

imagesc(1:2, 1:nfreq,z);
set(gca, 'YTick', 1:nfreq, 'XTick',1:2);
set(gca, 'YTickLabel',num2str(freqs'));
set(gca, 'XTickLabel', {'Pre' 'Onset'});
set(gca,'box', 'off');
if i > 1
    set(gca, 'XTick', [], 'YTick', []);
end

set(gca, 'TickDir', 'out', 'FontSize', 6, 'FontName', 'Times');
caxis(cx);
axis square;

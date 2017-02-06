function [] = plot_sig(p, alpha, ci, nfreq, stringent)

%Function to plot significance on the tiled plots created by plot_pf.
% Appear as black circles on the tiles

if nargin < 5; stringent = 0; end;

ind = find(isnan(p) == 0);
if ~isempty(ind)
    sig = fdr_vector(p(ind),alpha, stringent);
    %sig = p < alpha;
    s_ind = find(sig == 1);
    toplot = zeros(1,nfreq);
    toplot(ind(s_ind)) = 1;
    for pi=1:length(toplot)
        if toplot(pi)
            hold on;
            plot(ci, pi, '.k', 'LineStyle', 'none', 'MarkerSize', 10);
            hold off;
        end
    end
end
axis square;
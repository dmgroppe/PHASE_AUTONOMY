function [rho dim_max tau_max] = sproj_dim(x, dims, taus, Tp, doplot)

% Computes the simplex projection for different embedding dimensions, 
% and lags. Provides an empiricle method for determining the optimal embedding
% dimension.

if nargin < 5; doplot = false; end;

ndims = length(dims);
ntaus = length(taus);

for i=1:ntaus
    tau = taus(i);
    parfor j=1:ndims
        [rho(j,i),~,~] = sproj_rho(x, dims(j), tau, Tp, false);
    end
end

% Set the negative rhos to zero - as we are not interested in these
rho(find(rho < 0)) = 0;

% Find the indicies for the max dim, and tau for subsequent usage in other
% computations
rmax = max(max(rho));
[r c] = ind2sub(size(rho), find(rho == rmax));
dim_max = dims(r);
tau_max = taus(c);

% Plot results
if doplot
    cm = colormap('lines');
    hold on;
    for i=1:ntaus
        plot(dims, rho(:,i), '.-', 'Color', cm(i,:), 'MarkerSize', 10);
        axis([0 dims(end) 0 1]);
        axis square;
        ltext{i} = sprintf('Tau = %d', taus(i));
    end
    hold off;

    legend(ltext);
    xlabel('Embedding dimension');
    ylabel('Rho');
end


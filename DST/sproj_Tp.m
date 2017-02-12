function [rho] = sproj_Tp(x, dim, tau, Tps, doplot)

% Computes the simplex projection for different Tps

if nargin < 5; doplot = false; end;

parfor i=1:length(Tps)
    [rho(i),~,~] = sproj_rho(x, dim, tau, Tps(i), false);
end

% Set the negative rhos to zero - as we are not interested in these
rho(find(rho < 0)) = 0;

% Plot results
if doplot
    plot(Tps, rho, '.-', 'MarkerSize', 10);
    axis([0 Tps(end) 0 1]);
    axis square;
    xlabel('Tp');
    ylabel('Rho');
end


function [rho predicted observed] = sproj_rho(x, dim, tau, Tp, doplot)

% Computes the correlation between actual and predicted values from simplex
% projection.  Uses the first half of the time series to create the
% manifold, and the other half for prediction.
%
% USAGE: [rho predicted observed] = sproj_rho(x, dim, tau, Tp)
%
% Input:
%   x - the time series
%   dim - embedding dimension
%   tau - embedding lag
%   Tp - time step for range projection
%
% Output:
%   rho - the correlation between the actual value and the predicted value
%   predicted - predicted values
%   original - actualy values from the other half of the time series
%
% Taufik A Valiante 2012

if nargin < 5; doplot = 1; end;

Mx = phasespace(x,dim,tau);
Mx = Mx';
npoints = length(Mx);
start = fix(npoints/2)+1;
count = 0;
for i=start:(npoints-(Tp+1))
     count = count + 1;
     pred = simplex_projection(x(1:fix(npoints/2)), dim, tau, Tp, Mx(:,i));
     if ~isempty(pred)
         predicted(count) = pred;
     else
         predicted(count) = 0;
     end
     observed(count) = Mx(dim,i+Tp);
end

rho = corr(observed', predicted', 'type', 'Spearman');

if doplot
    h = figure(1);
    set(h, 'Name', 'Simplex projection forecasting');
    plot(observed, predicted, '.', 'LineStyle', 'None', 'MarkerSize', 10);
    legend(sprintf('R = %e', rho));
    xlabel('Observed');
    ylabel('Predicted');
    title(sprintf('Time step = %d', Tp))
end



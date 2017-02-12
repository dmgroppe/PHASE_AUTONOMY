function [pred] = simplex_projection(x, dim, tau, Tp, tpoint)

% Performs non-linear forecasting using the simplex projection method
% described by Sugihara and May 'Nonlinear forecasting as a way of
% distinguishing chaos from measurement error in time series'. Nature 1990.
%
% USAGE: [pred] = simplex_forecast(x, dim, tau, Tp, tpoint)
%
% Input:
%   x - the time series
%   dim - dimension for manifold reconstruction
%   tau - lag for embedding
%   Tp - number of time steps ahead to forecast 
%   tpoint - a vector of length dim to use as the starting point for the
%            forecast.  If empty forecasting will be done form the last
%            point of x
% Output:
%   pred - the forecast
%
% Taufik A Valiante 2012

if nargin < 5; tpoint = []; end;

if isrow(x)
    X = x';
else
    X = x;
end

% Create the Manifold
Mx = phasespace(X,dim,tau);
Mx = Mx';
L = length(Mx);

% Check the tpoint input
if ~isempty(tpoint)
    if min(size(Mx)) ~= length(tpoint)
        display('Dimensions of test point must be same as dim');
    else
        if isrow(tpoint)
            tpoint = tpoint';
        end
    end
end


if isempty(tpoint)
    % The last point is the 'predictee'
    lp = x((end-dim*tau+1):tau:end)';
else
    % Use the inputed point as the 'predictee'
    lp = tpoint;
end

% Get the domain simplex around this point
isimplex = nearestneighbour(lp, Mx, 'NumberOfNeighbours', dim+2);
if ~isempty(isimplex)
    isimplex(1) = [];

    % If the domain simplex is at a boundary reduce the dimension of the domain simplex 
    isimplex(find(isimplex > (L-Tp))) = [];

    if ~isempty(isimplex)
        % Compute the weights
        w = wi(lp, Mx(:,isimplex));

        % Advance the simplex into its range by specified number of time steps
        np = Mx(:,isimplex+Tp);

        % Get the prediction
        pred = 0;
        for j=1:numel(isimplex)
            pred = pred + w(j)*np(:,j);
        end

        % The last point is the forecast
        pred = pred(dim);
    else
        % This means that the entire simplex moved out of the manifold
        pred = 0;
    end
else
    pred = 0;
end

if isnan(pred)
    pred = 0;
end



function [y_mx r] = crossmap(x,y,dim,tau,doparallel)

% Cross mapping as described by Sugihara 2012 "Detecting causality
% in complex ecosystems" Science.  Computes Y|Mx - 'X xmap Y'.  
%
% USAGE: [y_mx r] = crossmap(x,y,dim,tau,doparallel)
%
% Input:
%   x - one time series
%   y - another time series
%   dim - embedding dimension
%   tau - embedding lag
%   doparallel - if multiple pools will split calculation to speed things
%   up, otherwise just do serially.
% Output:
%   y_mx - Y|Mx - the crossmapped estimate of manifold of Y
%   r - the out-of-sample correlation coefficient between the estimate and
%   the actual manifold of y
%
% Taufik A. Valiante 2012

if nargin < 5; doparallel = true; end;

% Create the manifolds
Mx = phasespace(x,dim,tau);
My = phasespace(y,dim,tau);

Mx = Mx';
My = My';
L = length(Mx);

% Use this when doing bootstrapping to make more efficient rather than
% blocking non-parallelized analyses

npools =  matlabpool('size');

if ~doparallel
    npools = 1;
end

if npools == 1
    % Just do calculations on whole block
    y_mx = get_y_mx(Mx, My, Mx, My, dim);
else
    % Create blocks of data to analyze
    blocksize = floor(L/npools);
    indicies = 1:blocksize:L;
    if indicies(end) ~= L;
        indicies(end) = L;
    end
    indicies(1) = 0;
    bl = [(indicies(1:(end-1))+1)', indicies(2:end)'];
    nblocks = size(bl,1);
    
    % Create the blocks
    for i=1:nblocks
        Mxblocks{i} = Mx(:,bl(i,1):bl(i,2));
        Myblocks{i} = My(:,bl(i,1):bl(i,2));
    end
    
    % Run the blocks
    parfor i=1:nblocks
        Ymx{i} = get_y_mx(Mxblocks{i}, Myblocks{i}, Mx, My, dim);
    end

    % Combine the blocks
    y_mx = [];
    for i=1:nblocks
        y_mx = [y_mx Ymx{i}];
    end
end

% Compute out-of-sample correlation coefficient
r = corr(y_mx(1,:)',y(1:length(y_mx))', 'type', 'Spearman');

% if isnan(r) == 1
%     a = 1;
% end

function [y_mx] = get_y_mx(Mxb, Myb, Mx, My, dim)


% Peforms the cross-map estimate

y_mx = zeros(dim,length(Mxb));

% Get all nearest neighbours
idxs = nearestneighbour(Mxb, Mx, 'NumberOfNeighbours', dim+2);

for i = 1:length(Myb)
    xt = Mxb(:,i); 
    idx = idxs(:,i);
    
    % nearestneighbour return the point itself so remove it
    idx(1) = [];
    
    % Get the weights
    w = wi(xt,Mx(:,idx));
    
    % Compute estimate from weights
    for j=1:numel(idx)
        y_mx(:,i) = y_mx(:,i) + w(j)*My(:,idx(j));
%         if max(max(isnan(y_mx))) == 1
%             a = 1;
%         end
    end
end


function [counts, xbins, ybins] = scatter_to_grid(x, y, dx, dy, xrange, yrange)

% Takes a scatter plot and make a histogram map out of it by sectioning the
% scatter in to voxels and computing counts for these voxels

if nargin < 6
    ybins = min(y):dy:max(y);
else
    ybins = yrange(1):dy:yrange(2);
end

if nargin < 5
    xbins = min(x):dx:max(x);
else
    xbins = xrange(1):dx:xrange(2);
end

for i=1:length(xbins)-1
    for j=1:length(ybins)-1
        xind = find(x >= xbins(i) & x < xbins(i+1));
        yind = find(y >= ybins(j) & y < ybins(j+1));
        
        cind = intersect(xind, yind);
        counts(j,i) = numel(cind);
    end
end

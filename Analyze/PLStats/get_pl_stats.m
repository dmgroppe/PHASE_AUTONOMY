% USAGE: [pl_stats] = get_pl_stats(pl_matrix, probbins, steps)
%   INPUT:
%       pl_matrix:  Matrix of the counts
%       probbins:   Number of probability bins to compute PL over
%       steps:      Number of times to rotate probbins around circle -
%                   averages the probability calculations
%   OUTPUT:
%       pl_stats:   Probability matrix
%
%  Copyright (C) 2011, Taufik A Valiante
%--------------------------------------------------------------------------

function [pl_stats] = get_pl_stats(pl_matrix, probbins, steps)

[r,c] = size(pl_matrix);
nbins = length(pl_matrix{1,1});
pl_stats = zeros(r,c);

for i=1:r
    for j=1:c
        pl_stats(i,j) = getp(pl_matrix{i,j}, nbins, probbins, steps);
    end
end


function [pl_mat] = pl_matrix(r, c, nbins)

% Usage: [pl_mat] = pl_matrix(r, c, bins)
%   Input:
%       r:      Number of rows in the PL matrix
%       c:      Number of columns in PL matrix
%       nbins:  Number of bins for phase angles

pl_mat = cell(r,c);
for i=1:r;
    for j=1:c
        pl_mat{i,j} = zeros(1,nbins);
    end
end
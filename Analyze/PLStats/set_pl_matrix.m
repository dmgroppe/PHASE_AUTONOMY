% Usage: function [] = set_pl_matrix(pl_matrix, wt, diff)
%   INPUT:
%       pl_matrix:  Cell matrix for arrays
%       wt:         Complex valued wavelet transform or if it a difference
%                   then it is the angle between two spectra (0->pi)

%       diff:       Is this a phase difference 1=yes, 2 = no
%                   if yes, then the range of angles is 0-pi,
%                   otherwise 0-2pi;
%
%       Bins phases across time and freq into nbins distributed equally
%       from 0 to 2pi or 0-pi (if a phase difference between two signals

function [pl_matrix] = set_pl_matrix(pl_matrix, wt, diff)

if (nargin < 3); diff = []; end;


[r,~] = size(pl_matrix);
nbins = length(pl_matrix{1,1});

if (strcmp(diff, 'diff'))
    index = ceil(wt*(nbins/pi));
else
    a = phase_diff(angle(wt));
    index = ceil((a+pi)*(nbins/(2*pi)));
end

% for i=1:r
%     for j=1:c
%         spot = index(i,j);
%         if (spot > nbins)
%             spot = 1;
%         end
%         pl_matrix{i,j}(spot) = pl_matrix{i,j}(spot) + 1;
%     end
% end

 for i=1:r
     pl_matrix(i,:) = set_row(pl_matrix(i,:), index(i,:), nbins);
 end

function [row] = set_row(row, index, nbins)

npoints = length(row);

for i=1:npoints
    spot = index(i);
    if (spot > nbins)
        spot = 1;
    end
    row{i}(spot) = row{i}(spot) + 1;
end
% USAGE: [pl] = compute_pl(spectra, params)
%
% Compute PL statistics for the 3D matrix contained in spectra
%
%   Input:
%       sepctra:    3D matrix (frq,points,epochs)
%       params:     analysis parameters
%   Output:
%       pl:         PL statistics

function [pl plm] = compute_pl(spectra, params, diff)

if (nargin < 3); diff = []; end;

[nfrq npoints nspectra] = size(spectra);

plm = pl_matrix(nfrq, npoints,params.pl.bins);

for p=1:nspectra
    plm = set_pl_matrix(plm, spectra(:,:,p), diff);
end

pl = get_pl_stats(plm, params.pl.probbins, params.pl.steps);
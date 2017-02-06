% USAGE [phist] = phase_histogram(pld)
%
%   Input:
%       pld:    Matrix of phase locking data in cell matricies (cond, subjects)
%               Each cell contains matrix of cells (nfrq, npoints)
%               Each cell contains an array of bins
%   Output:
%    phist:     nfrq - Histogram not includig the baseline period
function [phist] = phase_histogram(pld, dparams)

[nfrq ,~] = size(pld{1,1});
[ncond, nsubjects] = size(pld);
nbins = length(pld{1,1}{1,1});
bl_samples = time_to_samples(dparams.ana.baseline, dparams.data.srate);

phist = zeros(nfrq, nbins, ncond);
hist = zeros(nfrq,nbins);

for i=1:ncond
    hist(:,:) = 0;
    for j=1:nsubjects
        hist = hist + plm_hist(pld{i,j}, bl_samples);
    end
    phist(:,:,i) = hist;
end

function [hist] = plm_hist(plm, bl_samples)
%  Collpses a phase locking matrix across the rows (frequencies)

[nfrq npoints] = size(plm);
nbins = length(plm{1,1});
hist = zeros(nfrq, nbins);


for i=1:nfrq
    for j=(bl_samples+1):npoints
        hist(i,:) = hist(i,:) + plm{i,j};
    end
end

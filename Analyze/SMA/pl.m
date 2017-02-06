% USAGE: [pl] = pl(h1, h2, nbins, probbins, steps)
%
% PLV of Tass
%
%   h1,h2: hilber transforms of two signals
%   nbins:      number of bins to divide 2pi (usually 360)
%   probbins:   number of probability bins (usually 8)
%   steps:      number of time to caclulate PL whith a bin shift



function [pl] = pl(h1, h2, nbins, probbins, steps)
dphi = phase_diff((angle(h1) - angle(h2)));

counts = bin_dphi(dphi, nbins);
pl = getp(counts, nbins, probbins, steps);
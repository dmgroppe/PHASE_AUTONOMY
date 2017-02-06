function [counts]= bin_dphi(dphi, nbins)

counts = zeros(1,nbins);

delta = 2*pi/nbins;

bins = floor(dphi/delta) + 1;

for i=1:length(dphi)
    counts(bins(i)) = counts(bins(i)) + 1;
end

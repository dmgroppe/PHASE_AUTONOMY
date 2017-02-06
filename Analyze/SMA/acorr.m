% USAGE: [corr] = acorr(h1, h2)
%   Amplitude envelope correlation of two signals
%   h1, h2: hilber transforms of the two signals

function [corr] = acorr(a1, a2)

corr = fisherZ(pearson_corr(a1,a2));
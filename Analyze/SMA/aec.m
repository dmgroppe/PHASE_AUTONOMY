% USAGE: [corr] = corr(h1, h2)
%   Amplitude envelope correlation of two signals
%   h1, h2: hilber transforms of the two signals

function [corr] = aec(h1, h2)
a1 = abs(h1);
a2 = abs(h2);

corr = fisherZ(pearson_corr(a1,a2));
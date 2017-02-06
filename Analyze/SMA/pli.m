% USAGE: [plindex] = pli(h1, h2)
%
%   PLI of Stamm
%
%   h1, h2: hilber transforms of two band pass filtered signals 

function [plindex] = pli(h1, h2)
pdiff = phase_diff(angle(h1) - angle(h2));
npoints = length(h1);

plindex = sum(sign(pdiff))/npoints;
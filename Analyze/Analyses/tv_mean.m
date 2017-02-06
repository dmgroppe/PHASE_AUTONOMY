% USAGE: [m] = tv_mean(s)
%
%   Explicitly assumes that that s is one dimentional
%
%   Input:  s - one dimentional array
%   Output: m - mean

function [m] = tv_mean(s)
m = sum(s)/length(s);

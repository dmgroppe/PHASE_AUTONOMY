% USAGE: [R] = phase_coherence(h1, h2)
%
% Phase coherence of Mormann
%
%   h1: signal 1's hilbert transform of band pass filtered signal
%   h2: signal 2's hilbert transform of band pass filtered signal

function [R] = phase_coherence(h1, h2, var)

% If h1 and h2 are maticies then the rows are frequnecies and the colums
% are sucessive time points

pdiff = angle(h1) - angle(h2);
npoints = length(h1);

if min(size(pdiff)) == 1
    ssum = sum(sin(pdiff));
    csum = sum(cos(pdiff));
else
    ssum = sum(sin(pdiff),2);
    csum = sum(cos(pdiff),2);
end

R = sqrt((ssum/npoints).^2 + (csum/npoints).^2);

% pdiff = angle(h1) - angle(h2);
% npoints = length(h1);
% 
% ssum = sum(sin(pdiff));
% csum = sum(cos(pdiff));
% R = sqrt((ssum/npoints)^2 + (csum/npoints)^2);
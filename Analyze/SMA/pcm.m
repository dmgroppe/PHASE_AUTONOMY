% USAGE: [R] = phase_coherence(h1, h2)
%
% Phase coherence of Mormann
%
%   h1: signal 1's hilbert transform of band pass filtered signal
%   h2: signal 2's hilbert transform of band pass filtered signal

function [R] = pcm(h1, h2)
%pdiff = phase_diff(angle(h1) - angle(h2));
pdiff = phase_diff(angle(h1) - angle(h2));
mp = angle(sum(exp(1i*pdiff)));

pdiff = phase_diff(pdiff-mp);

R = mean(cos(pdiff));
function [p] = pulse(npoints, start, duration)

%   [p] = pulse(npoints, start, duration)
%   Creates a step starting at 'start', and of length 'duration' in
%   SAMPLES, not TIME.
% Input:
%   npoints:    Lenght of entire epoch
%   start:      Time to start the pulse
%   duration:   Duration of the pulse

per = 50;

p = zeros(1,npoints);
p(start:(start+duration)) = 1;

wpoints = fix(duration*per/100.0);
p = smooth(p,wpoints)';


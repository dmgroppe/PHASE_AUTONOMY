%  USAGE [wave] = sin_wave(freq, npoints, sr, phaseshift)
%
%   Input:
%       freq:       frequency of the sine wave
%       npoints:    Length of the synthetic data
%       sr:         Sampling
%       phaseshift  Phase shift of the sine wave in degrees
%   Output:
%       wave:       Synthetic wave
%-------------------------------------------------------------------------


function [wave] = sin_wave(freq, npoints, sr, phaseshift)

if (nargin < 4); phaseshift = 0; end

windowdur = npoints/sr;
delta = 2*pi/(npoints-1);
x = (1:npoints)*delta;
wave = sin(freq*windowdur*x+phaseshift);
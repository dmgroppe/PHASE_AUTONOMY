% USAGE [cgt] = cgt(y, dt, freqs, srate)
% Input:
%   y - the time series
%   dt - the charateristic time scale of interest
%   freqs - the frequencies of interest
%   srate - sampling rate of the data contained in y
% Output:
%   cgt - continuous gabor transform

function [cgt] = cgt(y, dt, freqs, srate)

 x = -1:1/srate:1;
 xl2 = fix(length(x)/2);
 
 % Set the charateristic time scale 
 s = dt/2; 
  
 cgt = zeros(length(freqs), length(y));
 parfor i=1:length(freqs)
     gb = gabor_1D(x, 0, freqs(i), s);
     t = conv(gb,y);
     cgt(i,:) = t(xl2:(end-xl2-1));
 end
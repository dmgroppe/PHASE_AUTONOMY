% USAGE: [plindex] = pli(h1, h2)
%
%   PLI of Stamm
%
%   h1, h2: hilber transforms of two band pass filtered signals 

function [wpli] = wpli(h1, h2)

icoh = imag(h1.*conj(h2));

wpli = sum(icoh)/sum(abs(icoh));


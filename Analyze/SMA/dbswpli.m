% USAGE: [wpli] = dbspli(h1, h2)
%
%   Debiased WPLI squared
%
%   h1, h2: hilber transforms of two band pass filtered signals 

function [wpli] = dbswpli(h1, h2)

icoh = imag(h1.*conj(h2));
isum = sum(icoh);
absisum = sum(abs(icoh));
ssq = sum(icoh.^2);

wpli = (isum^2 - ssq)/(absisum^2 - ssq);



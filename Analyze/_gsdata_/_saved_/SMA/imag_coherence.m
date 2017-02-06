function [ic] = imag_coherence(h1, h2)
%pdiff = (angle(h1) - angle(h2))/2;
 pdiff = angle(h1) - angle(h2);
 
 a1 = abs(h1);
 a2 = abs(h2);
 
 ic = mean(a1.*a2.*sin(pdiff))/sqrt(mean(a1.^2)*mean(a2.^2));
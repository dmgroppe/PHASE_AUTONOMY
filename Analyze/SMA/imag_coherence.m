function [ic] = imag_coherence(h1, h2)
%pdiff = (angle(h1) - angle(h2))/2;
 
pdiff = phase_diff(angle(h1) - angle(h2));
 
 a1 = abs(h1);
 a2 = abs(h2);
 
 if min(size(h1)) == 1
    ic = mean(a1.*a2.*sin(pdiff))/sqrt(mean(a1.^2)*mean(a2.^2));
 else
    ic = mean(a1.*a2.*sin(pdiff),2)./sqrt(mean(a1.^2,2).*mean(a2.^2,2));
 end
 
%  a1 = abs(h1);
%  a2 = abs(h2);
%  

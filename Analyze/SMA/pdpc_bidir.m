function [bidir] = pdpc_bidir(beta, dp, tau, f)

% Comuputes the phase depedant power correlation in the bidrectional
% coupling case as per Eriksson 2011.

wab = beta(1);
wba = beta(2);
Oba = wba*cos(2*pi*f*tau+dp);
Oab = wab*cos(2*pi*f*tau-dp);

top = 16*(wab^2 + wba^2) + 15*(1+wab^2)*Oba+15*(1+wba^2)*Oab+35*Oba.*Oab;
bottom = N(wab,Oab).*N(wba, Oba);

bidir = top./bottom;


function [num] = N(w, O)

num = sqrt(16*(1+w^4) + 5*O.*(6+6*w^2+7*O));
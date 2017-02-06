function [pdpc] = pdpc(beta,dp)

% Comuputes the phase depedant power correlation in the uni-directional
% coupling case as per Eriksson 2011.

w = beta(1);

cdp = cos(dp);

N = w*(16*w+15*cdp);
D = 4*sqrt((16*(1+w^4)+5*w*cdp.*(6+6*w^2+7*w*cdp)));

pdpc = N./D;
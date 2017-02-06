function [y] = ff_bidir(beta, dp)

% Fitting function for bidirectional case from Erikkson 2011

tau = beta(3);
f = beta(4);
nbeta = beta(1:2);

y = pdpc_bidir(nbeta, dp, tau, f);
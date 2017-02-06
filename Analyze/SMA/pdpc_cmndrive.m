function [y] = pdpc_cmndrive(beta, dp)

w = beta(1);
P = beta(2);

cdpmP = cos(dp-P);
cP = cos(P);

N = w^2*(15*cdpmP*(w+cP)+w*(16*w+15*cP));

A1 = sqrt(16*(1+w^4)+5*w*cP*(6+6*w^2+7*w*cP));
A2 = sqrt(16*(1+w^4)+5*w*cdpmP.*(6+6*w^2+7*w*cdpmP));
y = N./(A1*A2);

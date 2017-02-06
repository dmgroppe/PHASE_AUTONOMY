function [auc] = auc_simpsons(y, base, dx)

auc = 0;
for i=1:(length(y)-1)
    auc = auc + (y(i) + y(i+1)) - 2*base;
end

auc = 0.5*dx*auc;
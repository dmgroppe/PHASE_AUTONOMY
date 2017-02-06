% USAGE: getp(count, nbins, probbins, steps)
%
% Gets the phase locking value from a vector of counts

function [phase_locking] = getp(count, nbins, probbins, steps)

psize = floor(nbins/probbins);
p = zeros(1,probbins);
ntotal = sum(count);
plsum = 0;
Smax = log10(probbins);

for i=1:steps
    p(:) = 0;
    for k=1:probbins
        for j=((k-1)*psize):(k*psize-1)
            index = i+j;
            if (index > nbins)
                index = index-nbins;
            end
            p(k) = p(k) + count(index);
        end
    end
    result = 0;
    for k=1:probbins
        X = p(k)/ntotal;
        if (X ~= 0.0)
            result = result + X*log10(X)/Smax;
        end
    end 
    plsum = plsum + (1+result); 
end

phase_locking = plsum/steps;
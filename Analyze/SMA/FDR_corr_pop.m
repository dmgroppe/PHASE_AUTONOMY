function [sig pcut] = FDR_corr_pop(p, alpha)

nchan = length(p);
%c = sum(1./(1:nchan));
c = 1;

ps = ones(1,nchan*(nchan-1)/2);
count = 0;
for i=1:nchan
    for j=i+1:nchan
        count = count+1;
        ps(count) = p(j,i);
    end
end

ps = sort(ps,'ascend');

for j=1:count
    if (ps(j) > alpha*j/(count*c))
        pcut = ps(j);
        break;
    end
end

sig = zeros(nchan, nchan);
for i=1:nchan
    for j=i+1:nchan
        if (p(j,i) <= pcut)
            sig(j,i) = 1;
        end
    end
end
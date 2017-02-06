function [sig] = percentil(p, per)

nchan = length(p);
for i=1:nchan
    for j=i+1:nchan
        if (p(i) ~=0)
            plist(i) = p(i);
        end
    end
end

psort = sort(plist, 'ascend');

cutoff = per/100*nchan
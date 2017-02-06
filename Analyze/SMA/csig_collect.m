function [siglist] = csig_collect(csig)

N = length(csig);
sigcount = 0;
for i=1:N
    for j=i+1:N
        if (csig(j,i) ~= 0.0)
            sigcount = sigcount + 1;
            siglist(sigcount) = csig(j,i);
        end
    end
end
function [sig, pcut] = FDR_corr(oldp, alpha, stringent)

if nargin < 3; stringent = 0; end;

nchan = length(oldp);

c = 1;

pcut = zeros(1,nchan);
sig = oldp;

for i=1:nchan
    ps = collectps(oldp, i);    
    ps = sort(ps);
    
    for j=nchan:-1:1
        if stringent
            c = sum(1./(1:i));
        end
        if (ps(j) <= alpha*j/(nchan*c))
            pcut(i) = ps(j);
            break;
        end
    end
    sig = sig_set(sig, oldp, i, pcut(i));
end

% Set the other half of the grid to zero and diagnals
for i=1:nchan
    for j=i:nchan
        sig(i,j) = 0.0;
    end
end

function [ps] = collectps(oldp, ch)
% collected all the p values for a give channel ch

N = length(oldp);
ps = ones(1,N);

for i=1:ch
    ps(i) = oldp(ch,i);
end

for i=ch+1:N
    ps(i) = oldp(i, ch);
end

function [sig] = sig_set(sig, oldp, ch, pcut)
N = length(sig);

for i=1:ch
    if (oldp(ch,i) > pcut)
        sig(ch, i) = 0;
    else
        sig(ch,i) = 1;
    end
end

for i=ch+1:N
    if (oldp(i, ch) > pcut)
        sig(i,ch) = 0;
    else
        sig(i,ch) = 1;
    end
end
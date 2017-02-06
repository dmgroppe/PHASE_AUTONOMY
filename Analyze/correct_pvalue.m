% Usage [corrp, actp] =  correct_pvalue(p, alpha)
%
%   Input:
%       p:      p-values 
%       alpha:  uncorrected p-value
%   Output:
%       corrp:  Corrected p-values accoring to Bonnferoni-Holm approach
%       actp:   The actualy p-value used at each frequency.
%
%   Copyright (C) Taufik A Valiante 2011


function [corrp, actp] =  correct_pvalue(p, alpha)

if (nargin < 2); alpha = 0.05; end;

[nfrq, npoints] = size(p);
a = alpha*(1:npoints)/npoints;
corrp = zeros(nfrq, npoints);
actp = zeros(1,nfrq);

actp(:) = alpha;

for i=1:nfrq
    sorted = sort(p(i,:));
    %plot(1:npoints, sorted, 1:npoints,a);
    
    sigindex = 0;
    
    for j=npoints:-1:1
        if (sorted(j) < a(j))
            sigindex = j;
            break;
        end
    end
    
    if (sigindex)
        pcut = sorted(sigindex);
        actp(i) = pcut;
        for j=1:npoints
            if (p(i,j) < pcut)
                corrp(i,j) = 1;
            end
        end
    end
end
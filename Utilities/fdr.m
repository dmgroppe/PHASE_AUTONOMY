function [sig, pcut] = fdr(p, alpha, stringent)

% FDR as per Benjamini, Y. and Y. Hochberg (1995). "Controlling the False Discovery Rate:
% A Practical and Powerful Approach to Multiple Testing." J R Stat Soc B 57(1): 289-300.
%
% USAGE: [sig, pcut] = fdr_vector(p, alpha, stringent)

% INPUT:
%   p - vector of p values
%   alpha - significance level (ie. 0.05)
%   stringent - if 0 c=1, summed otherwise
% OUTPUT:
%   sig  - significant elements of p
%   pcut - cut off value for p

% Taufik A Valiante 2011

if nargin < 3; stringent = 0; end

pvec = reshape(p,1,numel(p));
N = length(pvec);
sp = sort(pvec,'ascend');

if stringent
    cn = fliplr(cumsum(1./(1:N)));
else
    cn = 1;
end

r = alpha*(N:-1:1)./(N*cn);
ind =  find((sp >= r) == 1,1);
pcut = sp(ind);

if ~isempty(pcut)
    sig = (p <= pcut);
else
    sig = zeros(size(p));
end


% 
% c = 1;
% 
% pcut = 0;
% sig = zeros(1,N);
% 
% for i=N:-1:1
%     if stringent
%         c = sum(1./(1:i));
%     end
%     
%     if (sp(i) < alpha*i/(N*c))
%         pcut = sp(i);
%         break;
%     end
% end
% 
% sig(find(p <= pcut)) = 1;
% 
% % for i=1:N
% %     if(p(i) <= pcut)
% %         sig(i) = 1;
% %     end
% % end

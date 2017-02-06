function [nf] =  p_norm(f, fracDiscard)

%Key normalzation of data, by log tranforming since the values are non-normal,
%and then shifting such that fracDiscard are set to zero.

if nargin < 2; fracDiscard = .001; end;

[npoints, nchan] = size(f);
lf = log(f);
nf = zeros(npoints, nchan);
for i=1:nchan   
    [mu sigma] = normfit(lf(:,i));
    s = norminv(fracDiscard,mu,sigma);
    nf(:,i) = lf(:,i)- s;
    nf(find(nf < 0)) = 0;
end


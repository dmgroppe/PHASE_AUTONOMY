function [rot] = rand_rotate(x, sshift)

x = x(:);
npoints = length(x);

if nargin < 2
    sshift = floor(rand*npoints)+1;
end

if ~isrow(x)
    x = x';
end

rot = [x(sshift:end) x(1:sshift-1)];
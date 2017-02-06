% USAGE: [plindex] = zero_phase(h1, h2)
%
%   Calculates the fraction of point that have zero phase difference
%
%   h1, h2: hilber transforms of two band pass filtered signals 

function [zph] = zero_phase(h1, h2)
pdiff = angle(h1) - angle(h2);
npoints = length(h1);

zph = 0;
for i=1:npoints
    if (pdiff(i) == 0)
        zph = zph + 1;
    end 
end

zph = zph/npoints;
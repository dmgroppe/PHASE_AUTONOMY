function [adist, phi] = amp_dist(comp, nbins)

% comp - an N x 2 matrix with the first element the phase, and the second
% element the amplitude


% Assume the phase angles are from -pi to pi

delta = 2*pi/nbins;

bin_index = fix((comp(1,:)+pi)/delta) + 1;

adist = zeros(1,nbins);
for i=1:nbins
    adist(i) = mean(comp(2,find(bin_index == i)));
end

phi = (0:(nbins-1))*delta - pi;





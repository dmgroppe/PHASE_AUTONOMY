function [P, Q, KLD, phi] = mod_index(comp, nbins)

% comp - an N x 2 matrix with the first element the phase, and the second
% element the amplitude


% Assume the phase angles are from -pi to pi

delta = 2*pi/nbins;

bin_index = fix((comp(1,:)+pi)/delta) + 1;

P = zeros(1,nbins);
for i=1:nbins
    P(i) = mean(comp(2,find(bin_index == i)));
end

phi = (0:(nbins-1))*delta - pi;
P = P/(sum(P));
Q = ones(1,nbins)/nbins;
%Q = ones(1,nbins) * min(P);
KLD = KL_distance(P,Q)/log10(nbins);






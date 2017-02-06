function [car] = Szprec_common_average_reference(d, excl)

nchan = size(d,2);

ch = setxor(1:nchan, excl);
car = d - repmat(mean(d(:,ch), 2), 1, nchan);


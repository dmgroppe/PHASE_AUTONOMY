function [s] = parab_fit(x,y)

%y = ax^2 + bx + c;
% returns [c b a];

sumx = sum(x);
sumx2 = sum(x.^2);
sumx3 = sum(x.^3);


l = [sum(y);sum(x.*y);sum((x.^2).*y)];
r(1,:) = [length(x) sumx sumx2];
r(2,:) = [sumx sumx2 sumx3];
r(3,:) = [sumx2 sumx3 sum(x.^4)];

s = r\l;


function [ll] = line_length1(x)
x = x(:);
l = abs(diff(x));
l(end+1) = l(end);
ll = cumsum(l)/length(x);
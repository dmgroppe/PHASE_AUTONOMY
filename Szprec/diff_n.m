function [x_diff] = diff_n(x, n)

if n == 1
    x_diff = diff(x);
    return;
end

% for the below it will be important that the returned array is one poitn
% shorter.

x = x(:)';
x_s = circshift(x,[0 -n]);
x_diff = x_s - x;
x_diff(((end-n):(end))) = x_diff(end-n-1);
x_diff = x_diff(1:(length(x)-1));





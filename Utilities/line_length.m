function [ll] = line_length(x, win)
x = x(:);
t = padarray(x,[fix(win/2)+1 0],'replicate');
l = abs(t(1:end-1)-t(2:end));
l(end+1) = l(end);
ll = average(l,win);
ll = ll(1:length(x));
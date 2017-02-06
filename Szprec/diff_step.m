function [d] = diff_step(x, step)

for i=1:(length(x)-step)
    d(i) = x(i+step-1)-x(i);
end

d =padarray(d',step, mean(d), 'post');
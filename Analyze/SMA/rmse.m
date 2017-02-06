function [rms] = rmse(x)

if size(x,1) > size(x,2)
    x = x';
end

N = size(x,1);

rms = 0;
for i=1:N
    for j=i+1:N
        rms  = rms + sqrt(mean((x(i,:) - x(j,:)).^2));
    end
end
rms = rms/(N*(N-1)/2);

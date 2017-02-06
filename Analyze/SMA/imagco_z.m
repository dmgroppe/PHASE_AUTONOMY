function [z] = imagco_z(C)

N = length(C);

v = (1-C.^2)*(atanh(abs(C)).^2)./(2*N*(C.^2));
stddev = sqrt(v./(N-1));
z = C./stddev;

for i=1:N
    for j=1:N
        if (isnan(z(i,j) ))
            z(i,j) = 0.0;
        end
    end
end
function [tmap] = tentmap(xstart, mu, iterations)

tmap(1) = xstart;
for i=2:iterations
    tmap(i) = tm(tmap(i-1),mu);
end


function val = tm(x,mu)

if x < 0.5
    val = mu*x;
else
    val = mu*(1-x);
end
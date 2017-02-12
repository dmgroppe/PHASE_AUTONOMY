function [L] = lorenz_gen(n, level, h)
s = 10;
r = 28;
b = 8/3;
x0 = 1;
y0 = 1;
z0 = 1;

[L.x, L.y, L.z] = lorentz(n,level,s,r,b,x0,y0,z0,h);





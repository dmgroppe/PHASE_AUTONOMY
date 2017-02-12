function dx = harmonic(t,x)

f1 = 140;
w0 = 8;
A = 10000;

dx(1) = -(2*pi*f1)^2*x(2) + A*cos(2*pi*w0*t);
dx(2) = x(1);

dx = dx';


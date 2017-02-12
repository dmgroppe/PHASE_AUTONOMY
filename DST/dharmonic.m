function dx = dharmonic(t,x, Z)

f1 = 140;
f2 = 160;
f3 = 8;
A = 5;

c12 = 0.01;
c21 = 0.01;

xl = Z(:,1);

dx(1) = -(2*pi*f1)^2*(x(2)-c12*x(4));
dx(2) = x(1)+A*cos(2*pi*f3*t);


dx(3) = -(2*pi*f2)^2*(-c21*xl(2)+ x(4));
dx(4) = x(3);

dx = dx';


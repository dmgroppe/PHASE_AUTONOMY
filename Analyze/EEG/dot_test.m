function [] = dot_test(n)

a1 = pi/8;
a2 = pi/16;

tic
for i=1:n
    a = real(dot(exp(-i*pi/8),exp(-i*pi/16)));
end
toc

tic
for i=1:n
    a = cos(pi/8)*cos(pi/16)+sin(pi/8)*sin(pi/16);
end
toc
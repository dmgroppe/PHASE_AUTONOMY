function [sol] = run_harmonic

sol = dde23(@harmonic, 0.007, [0 .001 0 .001], [1 2]);
x =1:.001:2;
y = deval(sol, x);
plot(x,[y(2,:)' y(4,:)']);
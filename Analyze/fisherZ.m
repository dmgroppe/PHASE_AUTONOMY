function [fz] = fisherZ(x)

fz = 0.5*log10((1.0+x)./(1.0-x));
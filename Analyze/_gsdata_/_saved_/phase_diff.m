function [d] = phase_diff(pd)

d = pi-abs(pi-abs(mod(pd,2*pi)));
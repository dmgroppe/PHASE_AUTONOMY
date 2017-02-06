function [c] = iic_Z(z)

c = z./abs(z).*tanh(abs(z));
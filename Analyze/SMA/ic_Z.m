function [z] = ic_Z(c)

z = c./abs(c).*atanh(abs(c));
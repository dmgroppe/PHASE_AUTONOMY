function [imag_var] = ic_variance(x1, x2)

coh = coherence(x1,x2);
c = mean(coh);
var = 1-
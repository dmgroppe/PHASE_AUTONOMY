function [plv] = phase_locking_value(h1, h2)

pdiff = phase_diff(angle(h1) - angle(h2));
plv = abs(mean(exp(1i*pdiff)));
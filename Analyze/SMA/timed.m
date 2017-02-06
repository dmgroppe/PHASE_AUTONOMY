function [td] = timed(h1, h2, freq)

pdif = phase_diff(angle(h1)-angle(h2));
td = fix(angle(sum(exp(1i*pdif)))/(2*pi)/freq*1000);



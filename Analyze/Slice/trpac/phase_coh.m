function [pac, pac_angle] = phase_coh(h1, h2, lfrange, ncycles, srate, ic)

if nargin < 6; ic = 0; end

R = h1.*conj(h2)./(abs(h1).*abs(h2));
win = fix(ncycles/mean(lfrange)*srate);
t = padarray(R',[fix(win/2)+1 0],'replicate');

if ic
    pac = abs(average(imag(t),win));
else
    pac = abs(average(t,win));
end
pac_angle = angle(average(t,win));

pac = pac(1:length(h1));
pac_angle = pac_angle(1:length(h1));

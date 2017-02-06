function [h] = freq_flows(EEG, ch, cond, length, frange)

h = get_hilberts(EEG, ch, cond, length, frange);

[nchan npoints] = size(h);
f = zeros(nchan, npoints-1);
window = ceil(1/mean(frange)*EEG.srate);
for i=1:nchan
    f(i,:) = smooth(inst_freq(h(i,:), EEG.srate), window);;
end

plot(f');
coherence(hilbert(f(1)), hilbert(f(2)))


 
function [f] = inst_freq(h, srate)

ph = unwrap(angle(h));

phshift = ph(:,2:end);
dphi = smooth((phshift - ph(:,1:end-1))');
f = dphi*srate/(2*pi);
% x = 1:length(dphi);
% ax(1) = subplot(2,1,1);
% plot(x,f);
% ax(2) = subplot(2,1,2);
% plot(x,dphi);
% linkaxes(ax, 'x');



     
 
     
 
     
     
 
 
 
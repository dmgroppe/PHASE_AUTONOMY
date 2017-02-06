function [] = amp_at_phase(EEG, ch, frange, envrange, cond, peaks, widths)

%eDir = 'D:\Projects\Data\Vant\Figures\Phase Histograms\';

[tstart tend] = get_trange(cond, 60);
subr = get_subregion(EEG, tstart, tend);

% Create the filter
%Hd = bpfilter(frange(1), frange(2), EEG.srate);

% h1 = hilbert(tfilter(subr(ch(1),:), Hd));
% h2 = hilbert(tfilter(subr(ch(2),:), Hd));

h1 = hilbert(eegfilt(double(subr(ch(1),:)),EEG.srate, frange(1), frange(2)));
h2 = hilbert(eegfilt(double(subr(ch(2),:)),EEG.srate, frange(1), frange(2)));

a1 = abs(h1);
a2 = abs(h2);

a1h = hilbert(eegfilt(a1,EEG.srate, envrange(1), envrange(2)));
a2h = hilbert(eegfilt(a2,EEG.srate, envrange(1), envrange(2)));


dphi = (angle(h1) - angle(h2))/2;
dphi = phase_diff(dphi).*sign(dphi);

%[pval ~] = circ_rtest(dphi+pi);
%fprintf('\nRayleigh test: p = %7.5f, mean angle = %6.4f degrees\n', pval, angle(sum(exp(1i*dphi)))/(2*pi)*360);

% npeaks = length(peaks);
% nwidths = length(widths);
% 
% if (npeaks ~= nwidths)
%     display('Number of peaks does not equal number of widths.')
%     return;
% end
% 
% for i=1:npeaks
%     h = figure(i);
%     text = sprintf('Amp histo ch%d and ch%d, for peak at %6.4f radians, width of %6.4f radians',...
%         ch(1), ch(2), peaks(i), widths(i));
%     set(h, 'Name', text);
%     subplot(2,1,1);
%     [ah] = amp_histo(a1, dphi, peaks(i), widths(i));
%     hist(ah, 100);
%     title(sprintf('Amp of ch%d', ch(1)));
%     
%     subplot(2,1,2);
%     [ah] = amp_histo(a2, dphi, peaks(i), widths(i));
%     hist(ah, 100);
%     title(sprintf('Amp of ch%d', ch(2)));
% end
% 
% h = figure(npeaks + 1);
% set(h, 'Name', 'All amplitudes');
% subplot(2,1,1);
% hist(a1, 100);
% title(sprintf('ALL amp of ch%d', ch(1)));
% 
% subplot(2,1,2);
% hist(a2, 100);
% title(sprintf('ALL amp of ch%d', ch(2)));

h = figure(1);
text = sprintf('Amp phase histo');
set(h, 'Name', text);

subplot(2,1,1);
scatter(angle(a1h), a1,'.');
title(sprintf('Ch %d', ch(1)));

subplot(2,1,2);
scatter(angle(a2h), a2,'.');
title(sprintf('Ch %d', ch(2)));
    

function [ah] = amp_histo(amp, dphi, peak, width)

count = 0;
for i=1:length(dphi)
    if (abs(dphi(i)-peak) <= width)
        count = count + 1;
        ah(count) = amp(i);
    end
end








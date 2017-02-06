function [pac] = sl_trpac(x, pc, hfrange, lfrange, T, trange, dap)

% Performs time resolved PAC as per Cohen 2008 "Assessing transient
% cross-frequency coupling in EEG data" J. Neurosci Meth 168:494-499
% Then plot PAC vs PC to look for correlations in the two metrics

tindex = find(T >= trange(1) & T <= trange(2));

ncycles = 10; % Number of cycles of low freq to average over
pc_index = 9; % Index of PC which was precomputed passed as argument

d = window_FIR(hfrange(1), hfrange(2), dap.srate);
env = abs(hilbert(filtfilt(d.Numerator, 1, x(tindex))));
% wts = wt(findex,tindex);
% env =  mean(abs(wts),1);
figure(1);clf;
subplot(2,2,2);
[ps1, w, ~] = powerspec(env, dap.srate, dap.srate);
loglog(w,ps1);
title(sprintf('Power spectrum of high frequency envelope %d-%d Hz', hfrange(1), hfrange(2)));
xlabel('Feqs (Hz)');
ylabel('Power');


d = window_FIR(lfrange(1), lfrange(2), dap.srate);
x_low = filtfilt(d.Numerator, 1, x(tindex));
x_high = filtfilt(d.Numerator, 1, env);

h_low = hilbert(x_low);
h_high = hilbert(x_high);

R = h_low.*conj(h_high)./(abs(h_low).*abs(h_high));
win = fix(ncycles/mean(lfrange)*dap.srate);
t = padarray(R',[fix(win/2)+1 0],'replicate');
pac = abs(average(t,win));

pac = pac(1:length(tindex));
zpac = fisherZ(pac);
zpc = fisherZ(pc(pc_index,tindex));

ax(1) = subplot(2,2,1);
plot(T(tindex), smooth(zpac,dap.srate));
xlabel('Time (s)');
ylabel('PAC');
title('Z transformed PAC');

ax(2) = subplot(2,2,3);
plot(T(tindex), smooth(zpc,dap.srate));
linkaxes(ax, 'x');
xlabel('Time (s)');
ylabel('PC');
title('Z transformed PC');

subplot(2,2,4);
plot(zpac, zpc, '.', 'MarkerSize', 1, 'LineStyle', 'none');
xlabel('PAC');
ylabel('PC')
[rho, pval] = corr(zpac, zpc', 'type', 'Spearman');
title(sprintf('rho = %6.4f, pval = %6.4e', rho, pval));

function [x] = average(x,win)
c   = cumsum(x)./win;
x   = [c(win); c((win+1):end)-c(1:(end-win))];
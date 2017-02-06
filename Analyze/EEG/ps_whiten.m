function [beta] = ps_whiten(d,ch, window,srate, frange)

x = d.data(ch,:);

[ps, w, ~] = powerspec(x, window,srate);
xind = find(w>=frange(1) & w<= frange(2));
ws = w(xind);
beta =  nlinfit(ws,ps(xind),@powerfun,[ps(1) -1], statset('Robust', 'on'));

res = ps(xind) - powerfun(beta, ws);

figure(1);
loglog(ws,ps(xind),ws,powerfun(beta,ws));
xlabel('Freq Hz');
ylabel('Power (/muV^2/Hz)');
legend({'Power spectrum', 'Fit'});

figure(2);
semilogx(ws,res);
xlabel('Freq Hz');
ylabel('Power (/muV^2/Hz)');
t = sprintf('A = %6.4f, exp = %6.4f', beta(1), beta(2));
title(t);
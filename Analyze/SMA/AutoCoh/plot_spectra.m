function [x1spec x2spec] = plot_spectra(x1, x2, srate, ltext)

[x1spec, ~, ~] = powerspec(x1,srate, srate);
[x2spec, w, ~] = powerspec(x2,srate, srate);

loglog(w,x1spec, w, x2spec);
legend(ltext);
xlabel('Freq Hz')
ylabel('Power');

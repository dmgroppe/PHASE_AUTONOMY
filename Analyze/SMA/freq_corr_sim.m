% USAGE: freq_corr_sim(dlength, ffreq, mfreq, harmonics, srate,
% mod_strength, nvar)

function [s] = freq_corr_sim(dlength, ffreq, mfreq, harmonics, srate, mod_strength, nvar)

fwave = sin_wave(ffreq, dlength, srate, 0);
mod = 1-mod_strength*(sin_wave(mfreq, dlength, srate, 0)/2 + 0.5);
noise = (0.5-rand(1,dlength))*nvar;


fwave = fwave.*mod;

harm = zeros(1,dlength);

for i=1:length(harmonics)
    harm = harm + (1/harmonics(i)*10)*sin_wave(harmonics(i)*ffreq, dlength, srate, 0).*mod;
end

s = fwave + harm;

x = (1:dlength)/srate;

if nargout == 0
    nplot = 4;
    figure(1);
    ax(1) = subplot(nplot,1,1);
    plot(x,fwave);

    ax(2) = subplot(nplot,1,2);
    plot(x,harm);

    ax(3) = subplot(nplot,1,3);
    plot(x,noise);

    ax(4) = subplot(nplot,1,4);
    plot(x,s+noise);

    linkaxes(ax, 'xy');
end


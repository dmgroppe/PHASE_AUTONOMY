function [F] = f_multichan(afunc, d, srate, refchans, channels, cfg, doplot)

if nargin < 6; doplot = 0; end;

parfor i=1:length(refchans)
    ind = intersect(refchans(i),channels);
    if ~isempty(ind)
        chlist = channels;
        chlist(ind) = [];
    else
        chlist = channels;
    end
    F(:,:,i) = compute_F(afunc, d, srate, i, chlist, cfg, 1);
end

if doplot
    m = squeeze(mean(F,3));
    T = (0:(length(m)-1))/srate;
    if size(m,1) == 1
        plot(T, m);
        axis([T(1) T(end) ylim]);
        xlabel('Time(s)');
        ylabel('Precursor');
    else
        surf(T,cfg.freqs,m);
        axis([T(1) T(end) cfg.freqs(1) cfg.freqs(end) min(min(m)) max(max(m))]);
        view(0,90);
        shading interp;
        title('Precursor - multichannel');
        xlabel('Time(s)');
        ylabel('Freq(Hz)');
    end
end

function m = compute_F(afunc, d,srate,ch1, chlist, cfg, domean)

if nargin < 6; domean = 0; end;

for i=1:length(chlist)
    F(:,:,i) = f_spectrum(afunc, d, srate, ch1, chlist(i), cfg, false);
end

if domean
    m = squeeze(mean(F,3));
else
    m = F;
end
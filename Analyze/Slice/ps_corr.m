function [] = ps_corr(x, srate, window, frange, dostats)

% Computes the power correlations as per Masimore 2004 an dplots them. Can
% do stats to, which take a long time to look for significant correlations.

if nargin < 5; dostats = 0; end;
if nargin < 4; frange = []; end;

nsurr = 500;
alpha = 0.001;

[rho, w] = ps_correlation(x, window, srate);
nfreq = length(w);
text='PS correlation';

if ~isempty(frange)
    findex = find(w >= frange(1) & w <= frange(2));
else
    findex = 1:length(w);
end

set(gcf,'Name',text);
plot_rho(w(findex), rho(findex,findex));
title(text);
caxis([0 1]);

%plot_freq_ranges();

%[bic,waxis] = bicoher (x);

tic
if dostats

    rhos = zeros(nfreq, nfreq, nsurr);

    parfor i=1:nsurr
        [rhos(:,:,i), ~] = ps_correlation(x, window, srate, 1);
    end

    pinc = zeros(nfreq, nfreq);
    pdec = pinc;

    for i=1:nsurr
        index = find(rhos(:,:,i) > rho);
        pinc(index) = pinc(index) + 1;

        index = find(rho > rhos(:,:,i));
        pdec(index) = pdec(index) + 1;
    end

    pinc = (pinc+1)/nsurr;
    pdec = (pdec+1)/nsurr;

    [siginc pinccut] = FDR_corr_pop(pinc, alpha);
    [sigdec pdeccut] = FDR_corr_pop(pdec, alpha);

    h = figure(2);
    text = 'Sig PS Correlation)';
    set(h,'Name',text);
    plot_rho(w, rho.*siginc);
    title(text);
    caxis([-0.5 1]);

    h = figure(3);
    text=sprintf('Sig Dec Freq correlation %s %s CH %d (Massimore)', upper(ptname), upper(cond), ch);
    set(h,'Name',text);
    plot_rho(w, rho.*sigdec);
    title(text);
    caxis([0 1]);
    
end
toc

function [] = plot_rho(w, rho)

surf(w, w, rho);
axis([w(1), w(end),w(1),w(end), min(min(rho)), max(max(rho))]);
shading interp;
view(0,90);
xlabel('Freq (Hz)');
ylabel('Freq (Hz)');

title(text);
colorbar;
caxis([-0.5 1]);
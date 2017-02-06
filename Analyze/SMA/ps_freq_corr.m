function [rho w] = ps_freq_corr(EEG, cond, dlength, ch, ptname, window, dosave, dostats)

if nargin < 8; dostats = 0; end;
if nargin < 7; dosave = 0; end;

nsurr = 200;
alpha = 0.001;
color_axis = [0 1];
clength = 15;  % use the top 5% of the plot

[tstart tend] = get_trange(cond, dlength, ptname);
tstart = tstart/1000*EEG.srate;
tend = tend/1000*EEG.srate;
x = EEG.data(ch, tstart:tend);

% simulate some power modulations
%x = freq_corr_sim(length(x), 100, 4, [2 3 4 5], 1000, 0.5, 1);

[rho, w] = ps_correlation(x, window, EEG.srate);
nfreq = length(w);
text=sprintf('Freq correlation %s %s CH %d (Massimore)', upper(ptname), upper(cond), ch);

n = length(rho);
newrho = rho;

for i=1:n
    if i+clength > n
        iend = n-i;
    else
        iend = clength;
    end
    newrho(i:i+iend,i) = 0;
end

rmean = mean(mean(newrho));
rstd = sqrt(mean(mean((newrho-rmean).^2)));
%0.99
%threshold = rmean + 2.326*rstd;
%0.0999
threshold = rmean + 3.090232*rstd;

h=figure(1);
set(h,'Name',text);
plot_rho(w, rho);
title(text);
caxis(color_axis);

if dosave
    save_figure(h, get_export_path_SMA, text);
end




%plot_freq_ranges();

%[bic,waxis] = bicoher (x);

tic
if dostats

    rhos = zeros(nfreq, nfreq, nsurr);
    srate = EEG.srate;
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
    text=sprintf('Sig Inc Freq correlation %s %s CH %d (Massimore)', upper(ptname), upper(cond), ch);
    set(h,'Name',text);
    plot_rho(w, rho.*siginc);
    title(text);
    caxis(color_axis);
    if dosave
        save_figure(h, get_export_path_SMA, text);
    end

    h = figure(3);
    text=sprintf('Sig Dec Freq correlation %s %s CH %d (Massimore)', upper(ptname), upper(cond), ch);
    set(h,'Name',text);
    plot_rho(w, rho.*sigdec);
    title(text);
    caxis(color_axis);
    
    if dosave
        save_figure(h, get_export_path_SMA, text);
    end
    
    h = figure(4);
    text=sprintf('Thresholded Freq-corr increase %s %s CH %d (Massimore)', upper(ptname), upper(cond), ch);
    set(h,'Name',text);
    
    rinc = rho.*siginc;
    trho = rinc;
    trho(find(rinc < threshold)) = 0;
    
    plot_rho(w, trho);
    title(text);
    caxis(color_axis);
    
    if dosave
        save_figure(h, get_export_path_SMA, text);
    end
end
toc

function[] = plot_freq_ranges()

daspect([1,1,1]);

rectangle('Position',[4,62,4,11], 'LineWidth',1, 'EdgeColor', 'r');
rectangle('Position',[4,92,4,15], 'LineWidth',1, 'EdgeColor', 'r');
rectangle('Position',[4,92,4,15], 'LineWidth',1, 'EdgeColor', 'r');
rectangle('Position',[4,126,4,40], 'LineWidth',1, 'EdgeColor', 'r');

rectangle('Position',[92,126,15,40], 'LineWidth',1, 'EdgeColor', 'r');
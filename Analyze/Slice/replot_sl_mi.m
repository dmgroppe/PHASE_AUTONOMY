function [] = replot_sl_mi(fname)

ap = sl_sync_params();

Dir = 'D:\Projects\Data\Human Recordings\';
fpath = [Dir fname '.mat'];

if ~exist(fpath, 'file')
    display('File does not exist');
    display(fpath);
    return;
end

load(fpath);

lfrange = 2:30;
hfrange = 30:2:200;

[yfreq, xfreq] = size(MI);
tortMI = reshape([MI(:,:).tort], yfreq, xfreq);


% Plot the unmaksed MI 
h = figure(1);
clf('reset');
fname = sprintf('SYNC MI %d-%d %d-%d', lfrange(1),...
    lfrange(end), hfrange(1), hfrange(end));
set(h, 'Name', fname);
plot_mi(lfrange, hfrange, tortMI);
title('TORT');

% Plot the phase
h = figure(2);
clf('reset');
fname = sprintf('SYNC MI PHASE %d-%d %d-%d', lfrange(1),...
    lfrange(end), hfrange(1), hfrange(end));
set(h, 'Name', fname);
plot_mi(lfrange, hfrange, reshape([MI(:,:).phase], yfreq, xfreq));
title('PHASE');
caxis([-pi pi]);
save_figure(h, 'D:\Projects\Data\Human Recordings\', fname);

% Compute the statistical significance

mis = reshape(surr_mi, 1, numel(surr_mi));
surrogate_mean = mean(mis);
surrogate_std = std(mis);
p = 1-normcdf(abs(tortMI),abs(surrogate_mean),abs(surrogate_std));
psig = p;
psig(p > ap.alpha) = 0;
psig(p <= ap.alpha) = 1;

% pvec = reshape(p,numel(p),1);
% [~, pcut] = fdr_vector(pvec, ap.alpha, 0);
% 
% psig = p;
% psig(find(p > pcut)) = 0;
% psig(find(p <= pcut)) = 1;

if max(max(psig)) == 1
    
    % Plot the masked MI
    h = figure(3);
    fname = 'MI significance';
    set(h, 'Name', fname);
    
    csig = tortMI.*psig;
    plot_mi(lfrange, hfrange, csig);
    title(sprintf('Significant MI p = %4.2f',ap.alpha));
    
    save_figure(h, 'D:\Projects\Data\Human Recordings\', fname);
    
    % Compute the mean phase angle for the significant regions of MI
    phases = reshape([MI(:,:).phase], yfreq, xfreq);
    phases = phases(psig==1);
    pmean = circ_mean(phases);
    [pmean_sig, ~] = circ_rtest(phases);
    display(sprintf('Mean phase = %6.2d, pval = %e', pmean, pmean_sig));
    p0 = circ_mtest(phases,0, 0.0001);
    display(sprintf('Is different from zero = %d', p0));
    
end





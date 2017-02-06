function [] = sync_pinfocorr(EEG, chpair, ptname, cond, dobs, dosave)

%  Computes the phase-depedant power-information correlations amongst other
%  things and performs bootstrap statistics on this metric.

% Allow passing of different sync_params if needed
ap = sync_params();
    
if nargin < 6; dosave = 0; end;
if nargin < 5; dobs = 0; end;

warning off all;

% Check to see if the DTF 
switch ptname
    case 'vant'
        Dir = 'D:\Projects\Data\Vant\Info\';
    case 'nourse'
        Dir = 'D:\Projects\Data\Nourse\Info\';
end

fname = sprintf('ADTF_%s.mat', cond);
fpath = [Dir fname];
if ~exist(fpath, 'file')
    display(sprintf('%s - does not exist.', fname));
    return;
end

% Load the ADTF file with the DTF time series
display('Loading aDTF time series...');
load(fpath);

 % legend text
l1 = sprintf('%d->%d', chpair(1), chpair(2));
l2 = sprintf('%d->%d', chpair(2), chpair(1));

% DTF.labels
% DTF.locations
% DTF.frequency
% DTF.matrix
% DTF.type
% DTF.isadtf
% DTF.srate

% Get the two time series of interest
% [R,C] = CH1->CH2;
adtf_fwd = squeeze(DTF.matrix(:,chn(chpair(2), ptname), chn(chpair(1), ptname), :))';
adtf_bkwrd = squeeze(DTF.matrix(:,chn(chpair(1), ptname), chn(chpair(2), ptname), :))';

% Set the frequencies from the DTF file

freqs = DTF.frequency(1):ap.pdpi.fredux:DTF.frequency(2);
ap.freqs = freqs;

[tstart tend] = get_trange(cond, ap.length, ptname);
subr = get_subregion(EEG, tstart, tend);

subr = subr(chpair,:);
npoints = length(subr);

% Get the wavelet transforms
display('Computing wavelet transforms...');
wt1 = twt(subr(1,:), EEG.srate, linear_scale(freqs, EEG.srate), ap.wnumber);
wt2 = twt(subr(2,:), EEG.srate, linear_scale(freqs, EEG.srate), ap.wnumber);

% Do simple correlation between

A1 = abs(wt1);
A2 = abs(wt2);

% Normalize the powers in each frequency so they are all 0 mean, 1 std
A1 = (A1-repmat(mean(A1,2), 1, npoints))./repmat(std(A1,1,2), 1, npoints);
A2 = (A2-repmat(mean(A2,2), 1, npoints))./repmat(std(A2,1,2), 1, npoints);

% Plot the various time series to make figures
h = figure(20);
clf('reset');
fig_name = sprintf('%s %s - Power-information time series', upper(ptname), upper(cond));
set(h, 'Name', fig_name);

samples = ((ap.pdpi.disp_seg(1)*EEG.srate):(ap.pdpi.disp_seg(2))*EEG.srate);
tseg = samples/EEG.srate;
findex = find(freqs == 140);

ax(1) = subplot(5,1,1);
plot(tseg,adtf_fwd(findex,samples));

ax(2) = subplot(5,1,2);
plot(tseg,adtf_bkwrd(findex,samples));

ax(3) = subplot(5,1,3);
plot(tseg,A1(findex,samples));

ax(4) = subplot(5,1,4);
plot(tseg,A2(findex,samples));

ax(5) = subplot(5,1,5);
pdif = phase_diff(angle(wt1(findex,samples)) - angle(wt2(findex,samples)));
gp = phase_diff(pdif - circ_mean(pdif));
plot(tseg, gp);

linkaxes(ax, 'x');

if ~dobs

    parfor i = 1:length(freqs)
        [rho1(i), ~] = corr(A1(i,:)',adtf_fwd(i,:)','type','Spearman');
        [rho2(i), ~] = corr(A2(i,:)',adtf_bkwrd(i,:)','type','Spearman');
    end

    h = figure(1);
    clf('reset');
    fig_name = sprintf('%s %d-%d DTF - power correlation', upper(ptname), chpair(1), chpair(2));
    set(h, 'Name', fig_name);

    subplot(2,1,1);
    plot(freqs, mean(adtf_fwd,2), freqs,mean(adtf_bkwrd,2));
    axis([freqs(1), freqs(end), 0, 0.5]);
    xlabel('Frequency (Hz)');
    ylabel('Average ADTF');
    legend({num2str(chpair(1)), num2str(chpair(2))});
    title('Average DTF as function of frequency');
    legend({l1,l2});


    subplot(2,1,2)
    plot(freqs, rho1, freqs, rho2);
    xlabel('Frequency (Hz)');
    legend({l1,l2});
    xlabel('Frequency (Hz)');
    ylabel('DTF-power correlations');
    title('DTF-Power correlatons');
    
    if dosave
        save_figure(h, get_export_path_SMA(), fig_name);
    end
    
    % Do an even simpler correlation between power of the source to the
    % information leaving the source by splitting the data in to segments
    
    tseg = 1:ap.ppc.window:length(A1);
    tr = [tseg(1:end-1)' (tseg(2:end)-1)'];
    nseg  = length(tr);
    findex = find(freqs >= ap.ppc.pow_dtf_freq(1) & freqs <= ap.ppc.pow_dtf_freq(2));
    
    
    for i=1:nseg
        dtf1(i) = mean(mean(adtf_fwd(findex,tr(i,1):tr(i,2))));
        p1(i) = mean(mean(A1(findex,tr(i,1):tr(i,2))));
        
        dtf2(i) = mean(mean(adtf_bkwrd(findex,tr(i,1):tr(i,2))));
        p2(i) = mean(mean(A2(findex,tr(i,1):tr(i,2))));
    end
    
    [b1, stats1, yfit1, S1] = stats(dtf1, p1);  
    [b2, stats2, yfit2, S2] = stats(dtf2, p2);
    
    h = figure(10);
    clf('reset');
    fig_name = sprintf('%s %d-%d DTF - PC Segments', upper(ptname), chpair(1), chpair(2));
    set(h, 'Name', fig_name);
    
    plot(p1,dtf1, '.b', 'LineStyle', 'none', 'MarkerSize', 15);
    hold on;
    plot(p1, yfit1, 'b');
    
    plot(p2,dtf2, '.g', 'LineStyle', 'none', 'MarkerSize', 15);
    plot(p2, yfit2, 'g');
    
    p1_stats = sprintf('%d->%d: R=%4.2f, p=%4.2e', chpair(1), chpair(2), S1.rho, S1.pval);
    p2_stats = sprintf('%d->%d: R=%4.2f, p=%4.2e', chpair(2), chpair(1), S2.rho, S2.pval);
    legend({p1_stats, p2_stats});
    
    set(gca, ap.pl.textprop, ap.pl.textpropval);
    set(gca, ap.pl.axprop, ap.pl.axpropval);
    
    xlabel('Power');
    ylabel('DTF');
    axis square;
    
    if dosave
        save_figure(h, get_export_path_SMA(), fig_name);
    end
    
    %return;

    nbins = ap.ppc.nbins;
    ctype = ap.ppc.ctype;
    [~,xbins] = make_phase_bins(ap.ppc.nbins);

    %% Phase-DTF correlation

    parfor i=1:length(freqs)
        Rfwrd(i) = sync_ph_var(wt1(i,:), wt2(i,:), nbins, ctype, adtf_fwd(i,:));
        Rbkwrd(i) = sync_ph_var(wt2(i,:), wt1(i,:), nbins, ctype, adtf_bkwrd(i,:));
        r_fwrd(i,:) = Rfwrd(i).rho;
        r_bkwrd(i,:) = Rbkwrd(i).rho;
    end

    zmax = max(max([r_fwrd r_bkwrd]));
    zmin = min(min([r_fwrd r_bkwrd]));
    ap.yaxis = [0 zmax];

    h = figure(2);
    fig_name = sprintf('%s %d-%d Phase-DTF correlation', upper(ptname), chpair(1), chpair(2));
    set(h, 'Name', fig_name);
    clf('reset');
    subplot(2,1,1);
    plot_ppc(xbins, r_fwrd, ap);
    title(sprintf('Phase-DTF correlation %d->%d', chpair(1), chpair(2)));

    subplot(2,1,2);
    plot_ppc(xbins, r_bkwrd, ap);
    title(sprintf('Phase-DTF correlation %d->%d', chpair(2), chpair(1)));
    
    if dosave
        save_figure(h, get_export_path_SMA(), fig_name);
    end

    %% Phase-dependant power-DTF correlation

    parfor i=1:length(freqs)
        Rpdpd_fwrd(i) = sync_ph_var(wt1(i,:), wt2(i,:), nbins, ctype, [A1(i,:)' adtf_fwd(i,:)']');
        Rpdpd_bkwrd(i) = sync_ph_var(wt2(i,:), wt1(i,:), nbins, ctype, [A2(i,:)' adtf_bkwrd(i,:)']');
        %Rpdpd_fwrd(i) = sync_ph_var(wt1(i,:), wt2(i,:), nbins, ctype, [A1(i,:)' adtf_bkwrd(i,:)']');
        %Rpdpd_bkwrd(i) = sync_ph_var(wt1(i,:), wt2(i,:), nbins, ctype, [A2(i,:)' adtf_fwd(i,:)']');

        r_fwrd(i,:) = Rpdpd_fwrd(i).rho;
        r_bkwrd(i,:) = Rpdpd_bkwrd(i).rho;
    end

    zmax = max(max([r_fwrd r_bkwrd]));
    zmin = min(min([r_fwrd r_bkwrd]));
    ap.yaxis = [0 zmax];

    h = figure(3);
    clf('reset');
    fig_name = sprintf('%s %d-%d Phase dependant power-DTF correlation', upper(ptname), chpair(1), chpair(2));
    set(h, 'Name', fig_name);
    subplot(2,2,1);
    plot_ppc(xbins, r_fwrd, ap);
    title(sprintf('Phase-dependant power-DTF correlation %d->%d', chpair(1), chpair(2)));

    subplot(2,2,3);
    plot_ppc(xbins, r_bkwrd, ap);
    title(sprintf('Phase-dependant power-DTF correlation %d->%d', chpair(2), chpair(1)));
    
        % Now fit the PDPD
    % This was better fit with the equation for Ericksson so instead of cosine
    % I will that, it is a "fit" nontheless
    xfit = -pi:0.1:pi;

    parfor i=1:length(freqs)
        warning off all;
        beta1 = nlinfit(xbins,r_fwrd(i,:),@ff_bidir, [0.5, 0.5,  Rpdpd_fwrd(i).mean_phase, freqs(i)]);
        Rfwd_fit(i,:) = ff_bidir(beta1, xfit);
        beta2 = nlinfit(xbins,r_bkwrd(i,:),@ff_bidir, [0.5, 0.5,  Rpdpd_bkwrd(i).mean_phase, freqs(i)]);
        Rbkwrd_fit(i,:) = ff_bidir(beta2, xfit); 

        % Compute the depth of the fit
        r_fwrd_depth(i) = max(Rfwd_fit(i,:)) - min(Rfwd_fit(i,:));
        r_bkwrd_depth(i) = max(Rbkwrd_fit(i,:)) - min(Rbkwrd_fit(i,:));
    end


    % Add the fitted subplots
    subplot(2,2,2);
    plot_ppc(xfit, Rfwd_fit, ap);
    title(sprintf('FIT: Phase-dependant power-DTF correlation %d->%d', chpair(1), chpair(2)));

    subplot(2,2,4);
    plot_ppc(xfit, Rbkwrd_fit, ap);
    title(sprintf('FIT: Phase-dependant power-DTF correlation %d->%d', chpair(2), chpair(1)));
    
    if dosave
        save_figure(h, get_export_path_SMA(), fig_name);
    end

    %% Phase-dependant power-information correlation plot

    h = figure(4);
    clf('reset');
    fig_name = sprintf('%s %d-%d Phase dependant power-DTF correlation FREQ PROFILE', upper(ptname), chpair(1), chpair(2));
    set(h, 'Name', fig_name);
    plot(freqs, r_fwrd_depth, freqs, r_bkwrd_depth);
    axis([freqs(1) freqs(end) 0 0.6]);
    xlabel('Frequency (Hz)');
    ylabel('PD-Power DTF corr');
    title('Phase depedant power-information correlation');
    legend({l1,l2});
    axis square;
    
    if dosave
        save_figure(h, get_export_path_SMA(), fig_name);
    end
            
    h = figure(5);

    % How is he information in the two direction correlated at the good phase?

    parfor i=1:length(freqs)
        warning off all;
        Rpdi(i) = sync_ph_var(wt1(i,:), wt2(i,:), nbins, ctype, [adtf_fwd(i,:)' adtf_bkwrd(i,:)']');
        rpdi(i,:) = Rpdi(i).rho;
        %beta = nlinfit(xbins,rpdi(i,:),@ff_bidir, [0.5, 0.5,  Rpdi(i).mean_phase, freqs(i)]);
        %beta = nlinfit(xbins,rpdi(i,:),@pdpc, 0.5);
        beta = nlinfit(xbins,rpdi(i,:),@cos_fit, [0 0.5]);
        %rpdi_fit(i,:) = ff_bidir(beta,xfit);
        %rpdi_fit(i,:) = pdpc(beta,xfit);
        rpdi_fit(i,:) = cos_fit(beta,xfit);
        rpdi_depth(i) = max(rpdi_fit(i,:)) - min(rpdi_fit(i,:));

    end

    clf('reset');
    subplot(3,1,1);
    ap.yaxis = [];
    plot_ppc(xbins, rpdi, ap);
    title('Phase depedant info-info correlation');

    ap.yaxis = [];
    subplot(3,1,2);
    plot_ppc(xfit, rpdi_fit, ap);
    title('FIT: Phase depedant info-info correlation');

    subplot(3,1,3);
    plot(freqs, rpdi_depth);
    axis([freqs(1) freqs(end) 0 0.1]);
    title('DEPTH: Phase depedant info-info correlation');
    xlabel('Frequency (Hz)');
    ylabel('DTF-DTF correlation');
    title('DTF-DTF correlation');

    % Do the statics on the phase-depen power-info correlations:
else
    
    fprintf('\nStarting: %s\n',datestr(now));
    display('Performing bootstrap statistics for PDPI...this will take a while!');
    
    % Do the statistics
    R = bs_phpinfo_corr(wt1, wt2, adtf_fwd, adtf_bkwrd, A1, A2, ap);
        
    % FDR correct
    sig_fwrd = fdr_vector(R.p_fwrd, ap.alpha, ap.fdr_stringent);
    sig_bkwrd = fdr_vector(R.p_bkwrd, ap.alpha, ap.fdr_stringent);
    
    % Ensure a minimum number of contiguous frequencies are significant
    [~,sig_fwrd] = sig_to_ranges(sig_fwrd, ap.freqs, ap.minr);
    [~,sig_bkwrd] = sig_to_ranges(sig_bkwrd, ap.freqs, ap.minr);
    
    % Plot it
    h = figure(6);
    clf('reset');
    fig_name = sprintf('PDPI Corr STATS %s %s %d-%d', upper(ptname), upper(cond), chpair(1), chpair(2));
    set(h,'Name', fig_name);
    
    plot(freqs, R.fwrd_depth, freqs, R.bkwrd_depth);
    hold on;
    plot(freqs, sig_fwrd*0.1, 'b');
    plot(freqs, sig_bkwrd*0.15, 'g');
       
    axis([freqs(1) freqs(end) 0 0.6]);
    
    xlabel('Frequency (Hz)');
    ylabel('PD-Power DTF corr');
    title('Phase depedant power-information correlation');
    legend({l1,l2});
    save_figure(h,get_export_path_SMA(), fig_name);
    save([get_export_path_SMA() fig_name '.mat'], 'R');
end

warning on all;

function [b, stats, yfit, S] = stats(amp, sync)
X = [ones(size(sync))', sync'];
[b,~,~,~,stats] = regress(amp',X);
yfit = b(1) + b(2)*sync;

set(0,'RecursionLimit',length(amp)*2);
[S.rho, S.pval] = corr(sync',amp','type','Spearman');        
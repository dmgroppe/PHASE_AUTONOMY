function [] = sync_mi_grid(EEG, lfrange, ch, hfrange, cond, ptname, dop)

if nargin < 7; dop = 0; end;

ap = sync_params();
nbins = ap.mi.nbins;


tpoints = length(hfrange)*length(lfrange);
nsurr = fix(ap.nsurr/tpoints);

% if nsurr == 0;
%     nsurr = 1;
% end
nsurr = ap.nsurr;

ts = data_retrieve(EEG, cond, ap.length, ptname);
ts = ts(ch,:);

if ap.mi.dosym
    [ts, low_osc, high_mod, noise] = sim_nesting(get_default_sim_params());
end

% Get low freq phase and high freq amplitude from wavelet transformed data
lf_wt = twt(ts, EEG.srate, linear_scale(lfrange, EEG.srate), ap.wnumber);
lf_phase = angle(lf_wt);
hf_env = abs(twt(ts, EEG.srate, linear_scale(hfrange, EEG.srate), ap.wnumber));

% Compute the MI matrix, also get the p-vale at the same time thorugh
% bootstrapping

surr_mi = zeros(length(hfrange), length(lfrange));

for i=1:length(lfrange)
    lfphase = lf_phase(i,:);
    parfor j= 1:length(hfrange)
        if dop
            [MI(j,i), p(j,i), surr_mi(j,i)] = sync_mi(lfphase, hf_env(j,:), nbins, nsurr, 1);
        else
            [MI(j,i), p(j,i), ~] = sync_mi(lfphase, hf_env(j,:), nbins, nsurr, 0);
        end
    end
end

% FDR correct the p value matrix

if dop
    %pvec = reshape(p,numel(p),1);
    %[~,pcut] = fdr_vector(pvec, ap.alpha, ap.fdr_stringent);
    mis = reshape(surr_mi, 1, numel(surr_mi));
        
    surrogate_mean = mean(mis);
    surrogate_std = std(mis);
    
    p = 1-normcdf(abs(MI),abs(surrogate_mean),abs(surrogate_std));
     
    %pvec = reshape(p,numel(p),1);
    %[~, pcut] = fdr_vector(pvec, ap.alpha, ap.fdr_stringent);
    psig = p;
    psig(find(p >= ap.alpha)) = 0;
    psig(find(p < ap.alpha)) = 1;
    
%     psig(find(p >= pcut)) = 0;
%     psig(find(p < pcut)) = 1;
    
    
%     for i=1:length(lfrange)
%         for j= 1:length(hfrange)
%             count(j,i) = length(find(surr_mi > MI(j,i)));
%         end
%     end
%     p = (count+1)/(numel(mis));
%     pvec = reshape(p,numel(p),1);
%     [~, pcut] = fdr_vector(pvec, ap.alpha, ap.fdr_stringent);
%     psig = p;
%     psig(find(p >= pcut)) = 0;
%     psig(find(p < pcut)) = 1;
    

%     sorted = sort(mis, 'descend');
%     sorted = unique(sorted);
%     mi_cut = sorted(fix(numel(sorted)*ap.alpha));
%     
%     psig = p;
%     psig(find(MI >= mi_cut)) = 1;
%     psig(find(MI < mi_cut)) = 0;
else
    
    psig = MI;
    psig(:,:) = 1;
end

h = figure(1);
clf('reset');
fname = sprintf('SYNC MI %s CH%d %d-%d & %d-%d', upper(ptname), ch, lfrange(1),...
    lfrange(end), hfrange(1), hfrange(end));
set(h, 'Name', fname);
subplot(2,1,1);
plot_mi(lfrange, hfrange, MI)

if max(max(psig)) == 1
    csig = MI.*psig;
    subplot(2,1,2);
    plot_mi(lfrange, hfrange, csig);
end

save_figure(h, get_export_path_SMA(), fname);

h = figure(2);
fname2 = [fname ' SYM'];
clf('reset');

npoints = ap.mi.pointstoplot;
if ap.mi.dosym
    ax(1) = subplot(5,1,1);
    t = ((1:npoints)-1)/EEG.srate*1000;
    plot(t,low_osc(1:npoints));
    ax(2) = subplot(5,1,2);
    plot(t,high_mod(1:npoints));
    ax(3) = subplot(5,1,3);
    plot(t,high_mod(1:npoints)+low_osc(1:npoints));
    subplot(5,1,4);
    ax(4) = plot(t, ts(1:npoints));
    subplot(5,1,5);
    ax(5) = plot(t, noise(1:npoints));
    linkaxes(ax, 'x');
    save_figure(h, get_export_path_SMA(), fname2);
    
else
    ax(1) = subplot(2,1,1);
    lowindex = find(lfrange == 8);
    highindex = find(hfrange == 140);
    t = ((1:npoints)-1)/EEG.srate*1000;
    plot(t,abs(lf_wt(lowindex,1:npoints)).*cos(lf_phase(lowindex,1:npoints)));
    ax(2) = subplot(2,1,2);
    plot(t,hf_env(highindex, 1:npoints));
    linkaxes(ax, 'x');
end







function [] = plot_mi(lfrange, hfrange, mi)

ap = sync_params();
%mi = 10*log10(abs(mi));
set(gcf, 'Renderer', 'painters');
surf(lfrange, hfrange, mi);
axis([lfrange(1), lfrange(end),hfrange(1),hfrange(end), min(min(mi)), max(max(mi))]);
axis square;
shading interp;
view(0,90);
caxis(ap.mi.caxis);
xlabel('Frequency (Hz)');
ylabel('Frequency (Hz)');
colorbar;


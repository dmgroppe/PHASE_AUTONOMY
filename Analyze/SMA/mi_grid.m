function [R] = mi_grid(ts, srate, lfrange, hfrange, doplot, mi_caxis, dosave, nbins, nsurr, alpha, wnumber)

if nargin < 11; wnumber = 5; end;
if nargin < 10; alpha = 0.05; end;
if nargin < 9; nsurr = 0; end;
if nargin < 8; nbins = 12; end;
if nargin < 7; dosave = false; end;
if nargin < 6; mi_caxis = []; end;
if nargin <5; doplot = 1; end;

% Get low freq phase and high freq amplitude from wavelet transformed data
lf_wt = twt(ts, srate, linear_scale(lfrange, srate), wnumber);
lf_phase = angle(lf_wt);
hf_env = abs(twt(ts, srate, linear_scale(hfrange, srate), wnumber));

trunc = fix(5/min(lfrange)*srate);

% Data is too short
if (trunc >= length(ts))
    error('Length of data is too short for given low frequency values.');
end

lf_phase = lf_phase(:,trunc:end-trunc);
hf_env = hf_env(:,trunc:end-trunc);


% Compute the MI matrix, also get the p-vale at the same time thorugh
% bootstrapping

surr_mi = zeros(length(hfrange), length(lfrange));

tic
parfor i=1:length(lfrange)
    lfphase = lf_phase(i,:);
    [MI(:,i),p(:,i), s_mi] = get_MI(lfphase, hf_env, hfrange, nbins, nsurr);
    if ~isempty(s_mi)
        surr_mi(:,i) = s_mi;
    end
end
toc

% Collect all the modulation indices and phases
mi = reshape([MI(:,:).tort], length(hfrange), length(lfrange));
mi_phase = reshape([MI(:,:).phase], length(hfrange), length(lfrange));

R.mi = mi;
R.mi_phase = mi_phase;
R.lfrange = lfrange;
R.hfrange = hfrange;
R.nbins = nbins;

% Get p-values if surrogates were computed
if nsurr
%     mis = reshape(surr_mi, 1, numel(surr_mi));
%         
%     surrogate_mean = mean(mis);
%     surrogate_std = std(mis);
%     
%     p = 1-normcdf(abs(mi),abs(surrogate_mean),abs(surrogate_std));
    psig = p;
    
    % FDR correct the p value matrix
    psig = reshape(fdr_vector(reshape(psig,1,numel(psig)),alpha,false), size(psig));
else
    psig = zeros(length(hfrange), length(lfrange));
end

R.psig = psig;

% Plot the results
if doplot

    h{1} = figure(1);
    clf('reset');
    fname = 'MI';
    set(h{1}, 'Name', fname);

    subplot(2,1,1);
    plot_mi(lfrange, hfrange, mi, mi_caxis);
    title('Modulation index')
    subplot(2,1,2);
    plot_mi(lfrange, hfrange, mi_phase, [-pi pi]);
    title('Modulation phase');

    if dosave
        save_figure(h{1}, get_export_path_SMA(), fname);
    end

    if nsurr && (max(max(psig)) == 1)
        fname = 'MI sig';

        h{2} = figure(2);
        clf('reset');
        set(h{2}, 'Name', fname);

        subplot(2,1,1);
        title('Modulation index')
        csig = mi.*psig;
        plot_mi(lfrange, hfrange, csig);

        subplot(2,1,2)
        phase_sig = mi_phase.*psig;
        plot_mi(lfrange, hfrange, phase_sig);
        title('Modulation phase');

        if dosave
            save_figure(h{2}, get_export_path_SMA(), fname);
        end
    else
        h{2} = [];
    end
end


function [MI p surr_mi] = get_MI(lfphase, hf_env, hfrange, nbins, nsurr)

surr_mi = [];

for j= 1:length(hfrange)
    if nsurr
        [MI(j), p(j), surr_mi(j)] = sync_mi(lfphase, hf_env(j,:), nbins, nsurr, 1);
    else
        [MI(j), p(j), ~] = sync_mi(lfphase, hf_env(j,:), nbins, nsurr, 0);
    end
end

function [] = plot_mi(lfrange, hfrange, mi, caxis_range)

if nargin < 4; caxis_range = []; end;

%mi = 10*log10(abs(mi));
set(gcf, 'Renderer', 'painters');
xvals = lfrange;
surf(xvals, hfrange, mi);
axis([xvals(1), xvals(end),hfrange(1),hfrange(end), min(min(mi)), max(max(mi))]);
set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'XScale', 'log', 'YScale', 'log', 'TickDir', 'out');
axis square;
shading flat;
view(0,90);

if ~isempty(caxis_range)
    caxis(caxis_range);
end
xlabel('Frequency (Hz)');
ylabel('Frequency (Hz)');
colorbar;


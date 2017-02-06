function [rho, p , mean_phase] = sync_phase_power_corr_grid(EEG, ch, cond, ptname, dosave, doplot, surr)

% Computes the Phase dependant power correlations described by Womelsdorf
% (2007), using wavelet transform.

if nargin < 7; surr = 0; end;
if nargin < 6; doplot = 0; end;
if nargin < 5; dosave = 0; end;

% Save the analysis info in AP
ap = sync_params();
ap.condlist{1} = cond;
ap.ptname = ptname;
ap.chlist = ch;

% Get the data
[tstart tend] = get_trange(cond, ap.length, ptname);
subr = get_subregion(EEG, tstart, tend);
subr = subr(ch,:);

% For surrogate generation
if surr
    if ap.scramble_phase
        subr(1,:) = scramble_phase(subr(1,:));
    else
        subr(1,:) = rand_rotate(subr(1,:));
    end
end

% Wavelet transforms

if ap.ppc.envlfp
    % USe the first channel specified
    [~, wt1, wt2] = sync_envlfp(EEG, ch(1), ptname, cond, ap.frange);
else
    wt1 = twt(subr(1,:), EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);
    wt2 = twt(subr(2,:), EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);
end


% The Sync-Power Corr for all the frequencies
for i=1:length(ap.freqs)
    [~, ~, rho(i,:), p(i,:), ~, mean_phase(i)] = sync_ppc(wt1(i,:), wt2(i,:), ap.ppc.nbins);
end

fname = sprintf('Phase-power corr %s %s %d&%d', upper(ptname), upper(cond), ch(1), ch(2));
[bins,x] = make_phase_bins(ap.ppc.nbins);

if dosave
% Package the results;
    R.rho = rho;
    R.p = p;
    R.ap = ap;
    R.mean_angle = mean_phase;
    R.bins = bins;
    R.x = x;
    save([get_export_path_SMA() fname '.mat'], 'R');
end

if doplot

    % DO FDR correction
    pvec = reshape(p,numel(p),1);
    [~,pcut] = fdr_vector(pvec, ap.alpha, ap.fdr_stringent);
    psig = p;
    psig(:,:) = 1;
%     psig(find(p >= pcut)) = 0;
%     psig(find(p < pcut)) = 1;


    % Only regions of a contiguous number of frequnecies are considered
    % significant

    for i=1:size(psig,2)
        [~,p_corr_sig(:,i)] = sig_to_ranges(psig(:,i), ap.freqs, ap.minr);
    end


    % In the phase direction 2 or more bins must be significant
     for i=1:size(psig,1)
          [~,p_corr_sig(i,:)] = sig_to_ranges(psig(i,:), 1:size(psig,2), 2);
     end

    % Lastly threshold the data - very arbitary
    trho = rho;
    trho(find(abs(rho) <= ap.ppc.threshold)) = 0;

    % Color the sig plot with RHO
    crho = p_corr_sig.*trho;
    pcrho = crho;

    % Get rid of the artifact at the extreme of the spectrum
    pcrho((end-ap.ppc.fremove):end,:) = 0;

    colormap(jet);
    h = figure(1);
    clf('reset');
    set(h, 'Name', fname);

    plot_ppc(x, pcrho, ap)

    if dosave
        save_figure(h, get_export_path_SMA(), fname,0);
    end

    h = figure(2);
    clf('reset');

    % Good phase plot

    subplot(2,2,1);
    fname = [fname ' GOOD'];
    set(h, 'Name', fname);

    % plot all mean_phase, unwrapped, times etc
    plot_ppc_goodphase(mean_phase, ap)


    % Save the figure as images
    if dosave
        save_figure(h, get_export_path_SMA(), fname);
    end
end

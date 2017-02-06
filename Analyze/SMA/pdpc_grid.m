function [rho, p, mean_phase, xbins] = pdpc_grid(x1, x2, srate, freqs, nbins, wnumber)


if nargin < 5; nbins = 24; end;
if nargin < 6; wnumber = 5; end;

wt1 = twt(x1, srate, linear_scale(freqs, srate), wnumber);
wt2 = twt(x2, srate, linear_scale(freqs, srate), wnumber);

% The Sync-Power Corr for all the frequencies
parfor i=1:length(freqs)
    [~, ~, rho(i,:), p(i,:), ~, mean_phase(i)] = sync_ppc(wt1(i,:), wt2(i,:), nbins);
end

[bins,xbins] = make_phase_bins(nbins);

% if dosave
% % Package the results;
%     R.rho = rho;
%     R.p = p;
%     R.ap = ap;
%     R.mean_angle = mean_phase;
%     R.bins = bins;
%     R.x = x;
%     save([get_export_path_SMA() fname '.mat'], 'R');
% end
% 
% if doplot
% 
%     % DO FDR correction
%     pvec = reshape(p,numel(p),1);
%     [~,pcut] = fdr_vector(pvec, ap.alpha, ap.fdr_stringent);
%     psig = p;
%     psig(:,:) = 1;
% %     psig(find(p >= pcut)) = 0;
% %     psig(find(p < pcut)) = 1;
% 
% 
%     % Only regions of a contiguous number of frequnecies are considered
%     % significant
% 
%     for i=1:size(psig,2)
%         [~,p_corr_sig(:,i)] = sig_to_ranges(psig(:,i), ap.freqs, ap.minr);
%     end
% 
% 
%     % In the phase direction 2 or more bins must be significant
%      for i=1:size(psig,1)
%           [~,p_corr_sig(i,:)] = sig_to_ranges(psig(i,:), 1:size(psig,2), 2);
%      end
% 
%     % Lastly threshold the data - very arbitary
%     trho = rho;
%     trho(find(abs(rho) <= ap.ppc.threshold)) = 0;
% 
%     % Color the sig plot with RHO
%     crho = p_corr_sig.*trho;
%     pcrho = crho;
% 
%     % Get rid of the artifact at the extreme of the spectrum
%     pcrho((end-ap.ppc.fremove):end,:) = 0;
% 
%     colormap(jet);
%     h = figure(1);
%     clf('reset');
%     set(h, 'Name', fname);
% 
%     plot_ppc(x, pcrho, ap)
% 
%     if dosave
%         save_figure(h, get_export_path_SMA(), fname,0);
%     end
% 
%     h = figure(2);
%     clf('reset');
% 
%     % Good phase plot
% 
%     subplot(2,2,1);
%     fname = [fname ' GOOD'];
%     set(h, 'Name', fname);
% 
%     % plot all mean_phase, unwrapped, times etc
%     plot_ppc_goodphase(mean_phase, ap)
% 
% 
%     % Save the figure as images
%     if dosave
%         save_figure(h, get_export_path_SMA(), fname);
%     end
% end

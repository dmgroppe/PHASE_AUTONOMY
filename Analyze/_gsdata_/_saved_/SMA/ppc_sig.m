function [pcrho] = ppc_sig(rho,p,ap)

% DO FDR correction
pvec = reshape(p,numel(p),1);
[~,pcut] = fdr_vector(pvec, ap.alpha, ap.fdr_stringent);
psig = p;
psig(find(p >= pcut)) = 0;
psig(find(p < pcut)) = 1;


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
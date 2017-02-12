function [S] = fNorm(F, pt_name, a_cfg)

% Selects the combinations of frequencies to use, the 'average' F values,
% normalization, and whether to multiply the precursor values by the rank.

F = F(a_cfg.stats.freqs_to_use,:,:);

% Normalize each frequency
for i=1:length(a_cfg.stats.freqs_to_use)
    S(i,:,:) = p_norm(squeeze(F(i,:,:)), a_cfg.stats.pNormPercentDiscard);
end

% Average the values across frequencies
switch a_cfg.stats.prec_weight 
   case 'max'
    S = squeeze(max(S(:,:,:),[],1));
   case 'mean'
    S = squeeze(mean(S(:,:,:),1));
   case 'median'
    S = squeeze(median(S(:,:,:),1));
end

% Normalize the data accordingly.

if a_cfg.stats.normalize
    if a_cfg.stats.rank_norm
        [rank, ~] = Szprec_rank1(F, a_cfg, a_cfg,pt_name);
        S = S.*rank;
    end
end
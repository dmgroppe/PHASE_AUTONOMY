function [pnorm] = vft_norm_pspectrum(tfa, cfg)

if ~isfield(tfa, 'wt'), error('individual spectra are required'); end
if ~isfield(cfg, 'btime'), error('baseline times are required'); end

ind = find(tfa.time>=cfg.btime(1) & tfa.time <= cfg.btime(2));

[nChan] = numel(tfa.wt);

for iCh = 1:nChan
    nTr = size(tfa.wt{iCh},1);
    sum = [];
    for iTr = 1:nTr
        wt = squeeze(abs(tfa.wt{iCh}(iTr,:,:)));
        bl = mean(wt(:,ind),2);
        pnorm{iCh}(iTr,:,:) = abs(wt)./repmat(bl,1,length(tfa.time));
    end
end
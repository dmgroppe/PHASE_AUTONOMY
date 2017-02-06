function [] = batch_pdpi_corr(EEG, ptname)

% Ensure some parameters are set in case sync_params changes
ap = sync_params();
ap.nsurr = 1000;
ap.fdr_stringent = 1;
ap.alpha = 0.05;

cond = {'aloud', 'quiet', 'rest_eo'};
ncond = numel(cond);
chpairs = pairs_all([8 16 60 49]);
npairs = size(chpairs,2);

for i=1:ncond
    for j=1:npairs
         sync_pinfocorr(EEG, chpairs(:,j), ptname, cond{i},1, ap);
    end
end
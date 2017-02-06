function [] = pfcorr_summary(R_start, R_pre)

cfg = cfg_default();

R_start.pfcorr(:,2,:) = []; % Keep the 'start' correlations
pfcorr = cat(2,R_start.pfcorr, R_pre.pfcorr); % Combine with 'pre' and 'onset' values

% Estimate the std from 0.7413*(interquartile range) to plot sem for the
% bounded line;
n_nans = numel(find((isnan(pfcorr)) == 1));
pfcorr_m = nanmedian(pfcorr,3);
sem = 0.7413*iqr(pfcorr,3)/sqrt(numel(pfcorr)-n_nans);


barweb(-pfcorr_m, sem,[],num2str(cfg.freqs'));
set(gca, 'TickDir', 'out', 'box', 'on', 'FontSize', 12, 'FontName', 'Times New Roman');
ylabel('Power-PA de-correlations');
xlabel('Hz');
legend({'start', 'pre', 'onset'}, 'Location', 'NorthEast');
fname = ('PFCORR SUMMARY');
set(gcf, 'Name', fname);
colormap(flipud(cbrewer('div',  'RdYlBu', 3)));


display('--- p-value summary');
c = combnk(1:3,2);
for i=1:length(cfg.freqs)
    for j=1:length(c)
        p(j,i) = pval(squeeze(pfcorr(i,c(j,1),:)), squeeze(pfcorr(i,c(j,2),:)));
    end
end

p
%display(sprintf('There are %d NaNs of total %d', numel(find((isnan(pfcorr)) == 1)), numel(pfcorr)));
        

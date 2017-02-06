function [pinc, pdec] = BonnerMS(nfig)

%if (nargin <2); corr = 0; end;

params = get_default_params();
params.export.export_results = 0;
params.pl.inclplcalcs = 0;
params.ana.chlist = [9 27];
params.ana.nsurr = 10;
alpha = 0.05;

test = 'passive';
cond = 'face';
R1 = get_BonnerEpochs(test, cond, params);

% tic
% [praw_inc, praw_dec] = ms_bootstrap(R1{1}, params);
% toc
% 
% pinc = correct_pvalue(praw_inc, alpha);
% pdec = correct_pvalue(praw_dec, alpha);



% epochs = get_epochs(R1);
% dparams = R1{1}.params;
% bl_samples = time_to_samples(dparams.ana.baseline, dparams.data.srate);
% subspectra = epochs{1}.spectra(:,bl_samples+1:end,:);
% tic
% [mp ms] = cross_freq_mod(subspectra);
% toc
% 
% figure(nfig);
% plot_cfmodulation(mp, ms, dparams, R1{1}.frq);






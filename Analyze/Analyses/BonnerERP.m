function [] = BonnerERP(alpha, corr)

if (nargin <2); corr = 0; end;

params = get_default_params();
params.export.export_results = 0;
params.pl.inclplcalcs = 0;
params.ana.chlist = [27];

test1 = 'scene';
cond1 = 'scene';
R1 = get_BonnerEpochs(test1, cond1, params);

test2 = 'face';
cond2 = 'scene';
R2 = get_BonnerEpochs(test2, cond2, params);

ERPStats(R1, R2, alpha, corr);




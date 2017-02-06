function [] = atten_analysis()

cfg = [];
cfg.channel = [9 27];
cfg.plot_channel = 27;
cfg.doplot = 0;
cfg.freq = [1:30 32.5:2.5:60 60:10:200];

%afiles = {'face1', 'face2', 'scene2', 'scene3', 'passive1', 'passive2'};
afiles = {'face2', 'face1'};
conds = {'face', 'scene'};

for i=1:numel(afiles)
    cfgs{i} = cfg;
    cfgs{i}.dfile = afiles{i};
end

parfor i=1:numel(afiles)
    R{i} = Bonner_preproc(cfgs{i});
end


% ----------------------Time resolved MI 

% lfind = find(R{1}.freq == 18);
% hfind = find(R{1}.freq >=60 & R{1}.freq<=200);
% 
% figure(1);
% mi = vft_tr_mi(R{1}.tfa{1}.wt{2}, lfind, hfind, 0, 1);
% plot_mi(mi,R{1}.time,cfg.freq(hfind),[0 1]);
% 
% cfg = [];
% cfg.btime = [-0.2 -0.1];
% [pnorm] = vft_norm_pspectrum(R{1}.tfa{1}, cfg);
% avg = squeeze(mean(pnorm{2},1));
% figure(2);
% clf;
% plot_tfa(avg,R{1}.time, R{1}.freq,'TFA');
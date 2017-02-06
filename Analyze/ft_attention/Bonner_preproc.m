function [R] = Bonner_preproc(trialfun, cfg)

if ~isfield(cfg, 'doplot');
    doplot = 0;
else
    doplot = cfg.doplot;
end

if ~isfield(cfg, 'channel'), error('you must specify channels to analyze'); end
if ~isfield(cfg, 'dfile'), error('you must specify the file type to be analyzed'); end
if ~isfield(cfg, 'freq'), error('you must specify the frequencies'); end
if ~isfield(cfg, 'plot_channel')
    if doplot
        error('you must specify a channel to plot if plotting is enabled');
    end
end


cfg = [];
cfg.trialdef.prestim = .2; % In s
cfg.trialdef.poststim = .8; % In s;

switch cfg.dfile
    case 'face1'
        [trl cfg] = 
        dataset = 'D:\Projects\Data\Attention\Bonner\Face1 BP 0.1 250 Dec500.cnt';
        exl = [17 23 24 51 52 53 58 64 83 102 107 117 118];
        %exl = [];
        trialfun = @Bonner_face1_trialfun;
    case 'face2'
        dataset = 'D:\Projects\Data\Attention\Bonner\Face2 BP 0.1 250 Dec500.cnt';
        exl = [2 3 8 14 15 36 38 45 51 64 65 68 69 76 81 86 95 120];
        trialfun = @Bonner_face2_trialfun;
    case 'scene1'
        dataset = 'D:\Projects\Data\Attention\Bonner\Scene1 BP 0.1 250 dec 500.cnt';
        exl = [2 3 8 14 15 36 38 45 51 64 65 68 69 76 81 86 95 120];
        trialfun = @Bonner_scene1_trialfun;
    case 'scene2'
        dataset = 'D:\Projects\Data\Attention\Bonner\Scene2 BP 0.1 250 Dec500.cnt';
        exl = [12 31 42 67 68 70 102 109 114 115];
        trialfun = @Bonner_scene2_trialfun;
    case 'scene3'
        dataset = 'D:\Projects\Data\Attention\Bonner\Scene3 BP 0.1 250 Dec500.cnt';
        exl = [12 31 42 67 68 70 102 109 114 115];
        trialfun = @Bonner_scene3_trialfun;
    case 'passive1'
        dataset = 'D:\Projects\Data\Attention\Bonner\Passive1 BP 0.1 250 Dec500.cnt';
        exl = [28 34 35 44 69 70 100 101 11 112 ];
        trialfun = @Bonner_passive1_trialfun;
    case 'passive2'
        dataset = 'D:\Projects\Data\Attention\Bonner\Passive2 BP 0.1 250 Dec500.cnt';
        exl = [8 11 14 15 18 33 34 35 43 47 49 60 97 98 107 112 113 114 120];
        trialfun = @Bonner_passive2_trialfun;
end

channels = cfg.channel;
R.labels = {'face', 'scene'};
R.cfg = cfg;
R.freq = cfg.freq;
dfile = cfg.dfile;

if doplot
    iCh = find(channels == cfg.plot_channel);
    if isempty(iCh)
        error('Channel to plot does not exist in analysis list');
    end
end
    
cfg = [];
[trl cfg] = trialfun(cfg);
face_trials = find(trl(:,5)==1);
scene_trials = find(trl(:,5)==2);

% Assume all trials are the same length
time = linspace(-cfg.trialdef.prestim, cfg.trialdef.poststim,trl(1,2)-trl(1,1)+1);

if 1
    % --------------View the data
    cfg.trl = trl;
    cfg.channel = channels;
    cfg.detrend = 'no';
    cfg.demean = 'yes';
    data = ft_preprocessing(cfg);
    cfg.viewmode = 'vertical';
    cfg.channel = data.label;
    ft_databrowser(cfg,data);
    R = [];
    return;
end


% % Compute the ERPs
% cfg = [];

% 
% % Do the face trials
% cfg.channel = 'all';
% cfg.covariance = 'no';
% % Only take those without artifacts
% cfg.trials =  setxor(intersect(face_trials, exl), face_trials);
% cfg.vartrllength = 2;
% 
% % Get face ERP
% tlf = ft_timelockanalysis(cfg, data);
% cfg.trials =  setxor(intersect(scene_trials, exl), scene_trials);
% cfg.vartrllength = 2;
% 
% % Get scene ERP
% tls = ft_timelockanalysis(cfg, data);
% 
% figure(1);
% plot(tlf.time,tlf.avg(1,:), tls.time, tls.avg(1,:));
% xlabel('Time (s)');
% ylabel('\muV');
% title('Hippocampus');
% legend({'Face-face', 'Face-Scence'});
% 
% 
% figure(2);
% plot(tlf.time,tlf.avg(2,:), tls.time, tls.avg(2,:));
% xlabel('Time (s)');
% ylabel('\muV');
% title('Visual cortex');
% legend({'Face-face', 'Face-Scence'});

cfg         = [];
cfg.btime = [-0.2 -0.1];
cfg.trl = trl;
cfg.dataset  = dataset;
cfg.channel = channels;
cfg.foi = R.freq;
cfg.bw = 5;
cfg.output = 'pow';
cfg.time = time;

R.freq = cfg.foi;

% Do face trials
cfg.trials = setxor(intersect(face_trials, exl), face_trials);
R.tfa{1} = vft_freqanalysis(cfg);

if doplot
    [R.pnorm{1}] = vft_norm_pspectrum(R.tfa{1}, cfg);
    avg = squeeze(mean(R.pnorm{1}{iCh},1));

    figure(1);
    clf;
    subplot(1,2,1);
    ttext = sprintf('%s - face', dfile);
    plot_tfa(avg,time, R.freq,ttext);
end

% Do scene trials
cfg.trials = setxor(intersect(scene_trials, exl), scene_trials);
R.tfa{2} = vft_freqanalysis(cfg);

if doplot
    [R.pnorm{2}] = vft_norm_pspectrum(R.tfa{2}, cfg);
    avg = squeeze(mean(R.pnorm{2}{iCh},1));

    subplot(1,2,2);
    ttext = sprintf('%s - scene', dfile);
    plot_tfa(avg,time, R.freq,ttext);
end

% -----------------Do the excluded trials
if ~isempty(exl)
    cfg.trials = exl;
    R.tfa_exl = vft_freqanalysis(cfg);
    if doplot
        [R.pnorm_exl] = vft_norm_pspectrum(R.tfa_exl, cfg);
        avg = squeeze(mean(R.pnorm_exl{iCh},1));

        figure(2);
        ttext = sprintf('%s - excluded', dfile);
        plot_tfa(avg,time, R.freq,ttext);
    end
end

R.trl = trl;
R.time = time;
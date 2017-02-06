function [] = plot_atten_trials(cfg)

if ~isfield(cfg, 'channel'), error('you must specify channels to analyze'); end
if ~isfield(cfg, 'trialdef'), error('you must specify trialdefs'); end
if ~isfield(cfg, 'dfile'), error('you must specify filetype to analyze'); end
if ~isfield(cfg, 'subject'), error('you must specify subject name'); end

trialfun = get_trialfunc(cfg.subject,cfg.dfile);

[trl cfg] = trialfun(cfg);

cfg.trl = trl;
cfg.detrend = 'no';
cfg.demean = 'yes';
data = ft_preprocessing(cfg);
cfg.viewmode = 'vertical';
cfg.channel = data.label;
ft_databrowser(cfg,data);

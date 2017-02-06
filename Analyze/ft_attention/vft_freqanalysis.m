function [tfa] =vft_freqanalysis(cfg)
% cfg.dataset Need the original data set
% cfg.trials = the trials to do the analyses on
% cfg.channel = channels to do the analysis on
% cfg.foi - the frequencies of interest
% cfg.bw - the band width parameter for the wavelet
% cfg.output - output of the 
% cfg.time - array of times

if ~isfield(cfg, 'bw')
    cfg.bw = 5;
end
if ~isfield(cfg, 'trials'), error('you must specify trials'); end
if ~isfield(cfg, 'trl'), error('you must specify a trl'); end
if ~isfield(cfg, 'channel'), error('you must specify channels'); end
if ~isfield(cfg, 'foi'), error('you must specify freqeuncies of interest'); end
if ~isfield(cfg, 'dataset'), error('you must specify the dataset for this analysis'); end
if ~isfield(cfg, 'time'), error('you must specify the time range'); end

data = ft_read_data(cfg.dataset);
hdr = ft_read_header(cfg.dataset);

% Only take the channels that are specified
data = data(cfg.channel, :);
nChan = size(data,1);

for iCh=1:nChan
    wt = twt(data(iCh,:), hdr.Fs, linear_scale(cfg.foi,hdr.Fs), cfg.bw);
    for iT = 1:length(cfg.trials)
        tr = cfg.trl(cfg.trials(iT),:);
        % Keep all the complex values spectra for further analyses
        tfa.wt{iCh}(iT,:,:) = wt(:,tr(1):tr(2));
    end
end

tfa.dimord = 'chan_freq_time';
tfa.freq = cfg.foi;
tfa.time = cfg.time;
tfa.cfg = cfg;

% Compute the powerspectrum as an average over all spectra
for iCh = 1:nChan
    tfa.powspctrm(iCh,:,:) = squeeze(mean(abs(tfa.wt{iCh}).^2,1));
end



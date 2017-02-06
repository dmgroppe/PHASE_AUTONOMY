function [cfg] = cfg_default_old()

cfg = [];
cfg.win = 1;                        % Divisor for number of sample points for fixed window (win = srate/cfg.win)
% For wavelet based precursor analysis
%cfg.freqs = [4:2:30 40:10:70 80:20:200]; 
cfg.freqs = [6 10 20 30 60 100];
cfg.wt_bw = 5;
cfg.bigmem = true;                  % This can only be used with lots of memory on board > 16GB typically
cfg.chtype = 'bipolar';             % Either 'bipolar', 'monopolar', 'car'
cfg.ch_to_excl = [];                % for CAR - the channels to exclude in the average

cfg.ncycles = 10;                   % Cycles of each frequency over which to compute the precursor
cfg.rank_mint = 750;                % Number points to use for the window rank (sample points);
cfg.rank_percentage = 0.8;          % The frank of points in a time window that need to be above rank_min (0-1);
cfg.rank_min = 0.95;                % The rank above which a channel value be considered to be included in the rank window (0-1)
cfg.useZ = 1;                       % Whether to use Z value for ranking the channels (for fband analysis only)
cfg.plot_multichan_caxis = [];      % When doing multichan plot can specific the caxis range
cfg.exclude_bad_channels = false;    % Exclude bad channels form ranking process
cfg.rank_across_freqs = true;       % This option takes the mean of F across all frequncies and saves this result
cfg.diff_adaptive = false;           % Default is derivative between each time point
                                    % If true the time between points will be
                                    % deternined by the number of radians and thus
                                    % frequency specific
cfg.diff_adaptive_rads = pi;        % Number of radians to take derivative across.
cfg.analysis = 'desync';            % Can be 'phase_coherence', 'desync', 'variance'


cfg.f_caxis = [0 3];
%cfg.f_caxis = [];

%% Convergent cross-mapping analysis defaults
cfg.ccm.doplot = 0;                 % Plot intermediary reults
cfg.ccm.win = 1;                    % Window over which to perform CCM (s)
cfg.ccm.dim = 2;                    % Embedding dimension
cfg.ccm.tau = 5;                    % NUmber of point steps to take when embedding
cfg.ccm.NSeg = 1;                   % NUmber of time to compute CCM over 
cfg.ccm.nsurr = 0;                  % For stats
cfg.ccm.Tps = 1:10;                 % Projection time (to compute as per Sugihara 1990)
cfg.ccm.poverlap = 0;               % Percent overlap for doing CCM over time segments
cfg.ccm.diff = false;               % Differentiate the time series (as per Sugihara)
    
cfg.ccm.dofreqs = 1;                % Do frequency ranges or use raw time series
cfg.ccm.freqs(:,1) = [4 8];
%cfg.ccm.freqs(:,2) = [8 14];
% cfg.ccm.freqs(:,3) = [15 20];
% cfg.ccm.freqs(:,4) = [20 25];
% cfg.ccm.freqs(:,5) = [25 30];
% cfg.ccm.freqs(:,6) = [30 60];
% cfg.ccm.freqs(:,7) = [60 100];
cfg.ccm.use_envelope = false;       % Use the envelope of the filtered time series

% Fquency specifications:
cfg.useFilterBank = false;           % Use band pass filtering rather than WAVELET
cfg.freqs = [6 10 20 30 60 100];
cfg.fband = [[4 8];[8 12];[15 20];[20 30];[30 60];[60 100]]';
cfg.use_fband = false; % This is not used anymore

%% F_BAND analysis
% Freqeuncy range for doing the precursor analysis
%cfg.fband = [[4 8];[9 14];[15 20];[20 30];[30 60];[60 200]]';        

cfg.fband_forder = 1000;            % Filter order for band pass filter
               
cfg.fband_use_ampenv = false;       % Use the ampltude envelope of the fband to do the computation
cfg.fband_ampenv_freqs = [4 8];     % In which frequency band to filter the amp envelope to do phase analyses
             % Perform frequency band analysis

%% STATS
cfg.stats.window = 1;             % Time window over which to compute stats
cfg.stats.poverlap = 0;             % Percentage overlap of the time windows
cfg.stats.nsurr = 10;
cfg.stats.maxiter = 1;

cfg.stats.use_fdr = 0;
cfg.stats.stringent = 0;
cfg.stats.tcond = {'L','R'};
cfg.stats.mint = 10; % Stats are done only after this time (s)
cfg.stats.global_p = true;
cfg.stats.use_max = 0;

cfg.stats.plot_onsets = 1;
cfg.stats.uCaxis = [-1000 5000];

cfg.stats.alpha = 0.01;
cfg.stats.bias = 0.01;
cfg.stats.lbp = 5;
cfg.stats.sm_window = 1; % smoothing window in seconds
cfg.stats.min_sz = 2;
cfg.stats.use_szend = false;
cfg.stats.rank_norm = true;

cfg.stats.ph_window = 5;
cfg.stats.ph_tf_freqs = [1:0.5:10 11:60 70:5:125];
cfg.stats.ph_tf_alpha = 0.01;
cfg.stats.ph_tf_onset_seg = 'pre'; % Can be from time zero 'start', or could be 'pre' (which is time segment up to the seizure start
cfg.stats.tf_parallelize = true; % In Szprec_ph_tf, parallelize over the seizures, sometimes they are too big to do this

cfg.stats.ph_fband_window = [10 30];  % Time window from 0 to this time to use for computing FBAND frequency dependency

cfg.stats.remap_electrodes = false;

cfg.stats.prec_weight = 'mean';
cfg.stats.use_marked_times = 'end';  % can be 'no', 'end', 'range'
cfg.stats.freqs_to_use = 1:6;
cfg.stats.use_sig_for_rank = true;
cfg.stats.min_sig_time = 2;
cfg.stats.ampAlpha = 0.5;
cfg.stats.ampStringent = false;
cfg.stats.normalize = true;
cfg.stats.pNormPercentDiscard = .01;

% Schematic plotting defaults
cfg.schematic.marker_size = 9;
cfg.schematic.font_size = 3;
cfg.schematic.font_name =  'Times New Roman';


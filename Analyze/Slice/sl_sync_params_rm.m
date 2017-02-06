function [ap] = sl_sync_params()
% ---- Directory information
ap.Dir = 'D:\Projects\Data\Human Recordings\Selected recordings for theta-gamma analysis\Set up 2\';
ap.ExportDir = [];
ap.fname = '11922007';
ap.comment = {};

% ---- Condition infomation
% For fname it is explicitly assumed that the files for the different
% conditons exist in the same directory

ap.cond.fname = {};     % Filenames for the various conditons
ap.cond.names = {};     % Names of the various conditions
ap.cond.times = [];     % Times of the various conditons
ap.chlabels = {};


% ---- Channel information
ap.ch = 1; % Channel to analyze
ap.srate = 2000;  % Sampling rate to decimate data to


% Data source
ap.load_mat = 1;

% ---- Notch filtering
ap.notches = [60 76 85];  % Starting frequncies for notch filtering
ap.notch = 1; % Do notch (1) or not (0)
ap.nharm = 5; % Number of harmonics to use for notch filtering
ap.bstop = 1; % Notch width in Hz

% ---- Power spectrum parametrs
ap.ps.nslep = 3;  % Number of slepian tapers for computing power spectrum
ap.ps.yaxis = [1e-9 1e-3]; % Range for power spectra
ap.ps.norm_yaxis = [1e-1 1e4];  % Range for normaalized yaxis
ap.ps.window = []; % Number of points over which to compute PS
ap.ps.usemt = 1;
ap.ps.normyaxis = [0.5 300];

% ---- Extracellular intracellular analyses
ap.icchan = 1;  % Intracellular channel
ap.ecchan = 2;  % Extracellular channel

% ---- Time frequency options
ap.wt.ostart = 3;
ap.wt.noctaves = 10;
ap.wt.nvoices = 4;
ap.wt.scale = 'log';
ap.wt.freqs = 50:5:250;
ap.wt.wnumber = 5;
ap.wnumber = 5;

ap.wt.plot_resample = 100;

% ---- Frequncy bands
ap.fb.names = {'delta', 'theta', 'alpha', 'beta', 'low-gamma', 'high-gamma'};
ap.fb.ranges = [[1 3]' [4 8]' [9 14]' [15 30]', [30 60]' [60 90]'];
ap.fb.sm_span = 20;         % Span over which to smooth data
ap.fb.sm_method = 'lowess'; % Smothing method
ap.fb.corr_window = 1000;   % Window over which to compute frequency correlations
ap.fb.yaxis = [-2 5];       % For plotting


ap.fb.mi.limit = 4;         % The minmal ratio between high frequencies and low frequency to use
ap.fb.mi.span = 1000;       % In ms
ap.fb.mi.overlap = 0;       % Percentage overlap
ap.fb.mi.dop = 0;           %  Do statistical analyses
ap.fb.mi.nsurr = 200;       % Number of surrogates
ap.fb.mi.nbins = 6;         % Number of phase bins to do mi calculation
ap.fb.mi.yaxis = [0 1e-2];  % For plotting

% Flags for doing the various analyses
ap.fb.do_corr = 0;          % Do the power correlation analyses?
ap.fb.do_mi = 1;            % Do MI analyses?


% ---- Special fields
ap.sf.names = {'Comment', 'ExportDir', 'Tags'};
ap.sf.vals = {};


%% Significance testing
ap.alpha = 0.05;
ap.fdr_stringent = 1;
%% Surrogate analysis
ap.nsurrch = 12;  % Number of surrogate channels
ap.nsurr = 200; % Number of surrogates to run
ap.surr = 0;
ap.scramble_phase = 0;
ap.surr2ndcond = 0;

% take abs of IC
ap.absic = 1;
ap.abs_all = 1;

ap.sync_freq_surr = 'time_shift';  % 'time_shift', or 'rand_pairs'
ap.nsurrch = 12; % Number of surrogate channels to generate 'rand_pairs'

%Mnorm parameters
ap.mnorm.highf = [125 165];
ap.mnorm.lowf = [6 8];

%Window for sync-power correlations
ap.window = 500;

% Window size for LOOM of calculating variances for continuous data, also
% used in the 2 channel sig testing utilizing K-S
ap.loom_compute = 0;
ap.loom_window = 5000;

% For n:m phase locking of two signals
ap.nmpl.lowf = [6 10];
ap.nmpl.highf = [125 165];
ap.nmpl.n = 1:10;
ap.nmpl.m = 1:0.5:30;


% Minmum frequency range over which to consider significance (Hz)
ap.minr = 40;

%% PPC: Phase power correaltion
ap.ppc.nbins = 12;
ap.ppc.fremove = 0;
ap.ppc.threshold = 0;
ap.ppc.binrange = [-pi/3 pi/3];
ap.wind_length = 100; % in ms
ap.plags = -100:100; % in ms
ap.ppc.window = 1000;
% Do the PPC calculation using the envelope range specified in 'ap.frange' with
% the LFP in the same channel over the range specified in 'ap.freqs'
ap.ppc.envlfp = 0;  


%% FPC - Instantaneous frequency and power relationship
ap.fpc.revrel = 0; % Shift the relationship to follow_amp and IEI
ap.fpc.amprange = [0 30];
ap.fpc.intrange = [0 20];


%% PLOTTING
ap.pl.show_axes = 1;
ap.pl.colorbar = 1;
ap.pl.ranges = 1;
ap.pl.zeroline = 1;
ap.yaxis = [0 0.6];
ap.plotsync = 0;
ap.pl.axis = 'linear';

ap.pl.textprop = {'FontName', 'FontSize'};
ap.pl.textpropval = {'Times', 7};

ap.pl.axprop = {'TickDir'};
ap.pl.axpropval = {'out'};



%% Low freq phase-high freq envelope histograms

ap.mi.nbins = 12;
ap.mi.dosym = 0;
ap.mi.pointstoplot = 2000;
ap.mi.caxis = [];
ap.mi.lfrange = 2:30;
ap.mi.hfrange = 30:2:200;

%% 2 freq PPC
ap.tfppc.window = 1000;

%% filters
ap.filter.ftype = 'firnotch';
ap.iirnotch.order = 10;
ap.iirnotch.ftype = 'butter';
ap.firnotch.order = 8000;
ap.firnotch.ExportDir = 'D:\Projects\Data\Human Recordings\Selected recordings for theta-gamma analysis\firnotch\'

%% Wavelet Phase Coherence
ap.wpc.freq = [4 50];
ap.wpc.scalsamp = 1;
ap.wpc.winsz = 1;
ap.wpc.overlap = 0.5;
ap.wpc.pltarrows = 0;
ap.wpc.arrcol = [];
ap.wpc.arrthr = [];
ap.wpc.wavname = 'cmor5-1';
ap.wpc.ExportDir = 'E:\Carlos Mario\Human tissue project\Characterization paper\Files for First paper\wpc\';

%% Continuous Wavelet Transform
ap.cwt.freq = [4 30];
ap.cwt.scalsamp = 2;
ap.cwt.wavname = 'cmor5-1';

%% Surrogate (Random Circular Time Translation)
ap.surr.nsurr = 1000;

end








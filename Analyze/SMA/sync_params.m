function [ap] = sync_params()

ap.condlist = {'quiet','rest_eo'};
%ap.condlist = {'rest_eo'};
ap.atype = 'ic';
ap.ptname = 'jolly';
ap.usewt = 1;
ap.wnumber = 5;

%ap.freqs =  2:50;
ap.freqs = [10:2:50 60:5:250];
%ap.freqs = 2:2:50;
ap.frange = [125 165];
ap.length = 60;

%% Significance testing
ap.alpha = 0.05;
ap.fdr_stringent = 1;
%% Surrogate analysis
ap.nsurrch = 12;  % Number of surrogate channels
ap.nsurr = 1000; % Number of surrogates to run
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

% smoothing parameters
ap.sm_span = 0;
ap.sm_method = 'moving';

%% Frequency ranges of significance

if strcmp (ap.ptname, 'vant')
    %ap.extrema_range(:,1) = [62 73];
    ap.extrema_range(:,1) = [92 107];
    ap.extrema_range(:,2) = [125 165];
    ap.extrema_range(:,3) = [200 400];
    ap.frange_names = {'g1', 'g2', 'g3'};
else
    ap.extrema_range(:,1) = [52 62];
    ap.extrema_range(:,2) = [111 127];
    ap.extrema_range(:,3) = [200 400];
    ap.frange_names = {'g1', 'g2', 'g3'};
end


% For Nourse
%ap.extrema_range(:,1) = [52 63];
%ap.extrema_range(:,2) = [111 127];


% Minmum frequency range over which to consider significance (Hz)
ap.minr = 5;

%% PPC: Phase power correaltion
ap.ppc.nbins = 36;
ap.ppc.fremove = 0;
ap.ppc.threshold = 0;
ap.ppc.binrange = [-pi/3 pi/3];
ap.wind_length = 100; % in ms
ap.plags = -100:100; % in ms
ap.ppc.window = 1000;
ap.ppc.pow_dtf_freq = [125 165];

% Do the PPC calculation using the envelope range specified in 'ap.frange' with
% the LFP in the same channel over the range specified in 'ap.freqs'
ap.ppc.envlfp = 0;  
ap.ppc.ctype = 'spearman';
ap.ppc.xfit_inc = 0.01;
ap.ppc.bin_trunc = 'none';  % Can be 'none', 'min', 'fraction';
ap.ppc.bin_trunc_fraction = 4;

% Phase-dependant power-information correlations
ap.pdpi.fredux = 1;
ap.pdpi.fit_type = 'cos';
ap.pdpi.disp_seg = [20 40]; % Display segment

%% FPC - Instantaneous frequency and power relationship
ap.fpc.revrel = 0; % Shift the relationship to follow_amp and IEI
ap.fpc.amprange = [0 30];
ap.fpc.intrange = [0 20];


%% PLOTTING
ap.pl.show_axes = 1;
ap.pl.colorbar = 1;
ap.pl.ranges = 1;
ap.pl.zeroline = 1;
ap.yaxis = [0 0.5];
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
ap.mi.caxis = [0 2e-2];

%% 2 freq PPC
ap.tfppc.window = 1000;

%% DTF
ap.dtf.order = 12;
ap.dtf.window = 0;
orders = [[1000 2000 3000 4000 5000]' [3 5 5 6 6]'];

if ap.dtf.window
    ap.dtf.order = orders(find(orders(1,:) == ap.dtf.window),2);
end

%% Freq depedant matrix
ap.fdm_freqs = [[.001 4 9 25 62 95 125 200]' [3 8 14 30 73 107 165 400]'];

%% Phase transitions
ap.phtrans.nbins = 36;
ap.phtrans.dwin = 5;

%% EMD
ap.emd.qResol = 50;
ap.emd.qResid = 50;
ap.emd.qAlfa = 1;
ap.emd.Nstd = 0.1;
ap.emd.NE = 100;

%% Convergent cross mapping
ap.ccm.dim = 3;
ap.ccm.tau = 1;
ap.ccm.npoints = 5000;
ap.ccm.dims = 3:10;
ap.ccm.Lsteps = 200:200:2000;
ap.ccm.Tps = 1:24;
ap.ccm.alpha = 0.05;
ap.ccm.nsurr = 200;
ap.ccm.Nseg = 200;
ap.ccm.frange = [125 165];

%--------------------------- AUTOCOHERENCE -------------------------------%

% % Current parameters for VANT Autocoherence analysis: CHANNEL 60
% ap.autocoh.dt = 0.050;  % Width of the Gabor atom to use for transform
% ap.autocoh.blength = []; % Maximal burst length, set to [] for all lengths
% ap.autocoh.minlength = 0;
% ap.autocoh.use_cv = true; % Use the CV to determine burst autocoherence
% ap.autocoh.cv = 0.05; % Value to use id using CV for AC
% ap.autocoh.decorr_angle = pi/4;
% ap.autocoh.bsize = 2;
% ap.autocoh.useall = false;
% ap.autocoh.nsurr = 1;
% ap.autocoh.prob_bin = 5;
% ap.autocoh.prob_maxburstlength = .200;
% ap.autocoh.prob_minburstlength = 0;
% ap.autocoh.prob_caxis = [0 0.05];
% ap.autocoh.freq_add = [100 135];
% ap.autocoh.amp_scale = [2.5 2];
% %ap.autocoh.amp_scale = [2.5 2];
% ap.autocoh.bfrac = [0.2 0.2];
% ap.autocoh.t_scale = [8 12];
% ap.autocoh.tol = 1e-3;
% ap.autocoh.olap = 0.2;
% ap.autocoh.minbursts = 50;
% ap.autocoh.check_fit = false;

% % %% Autocoherence analysis
% ap.autocoh.dt = 0.050;  % Width of the Gabor atom to use for transform
% ap.autocoh.blength = []; % Maximal burst length, set to [] for all lengths
% ap.autocoh.minlength = 0;
% ap.autocoh.use_cv = true; % Use the CV to determine burst autocoherence
% ap.autocoh.cv = 0.05; % Value to use id using CV for AC
% ap.autocoh.decorr_angle = pi/4;
% ap.autocoh.bsize = 2;
% ap.autocoh.useall = false;
% ap.autocoh.nsurr = 1;
% ap.autocoh.prob_bin = 5;
% ap.autocoh.prob_maxburstlength = .100;
% ap.autocoh.prob_minburstlength = 0;
% ap.autocoh.prob_caxis = [0 0.02];
% ap.autocoh.freq_add = [100 135];
% ap.autocoh.amp_scale = [3 2.2];
% %ap.autocoh.amp_scale = [2.5 2.2];
% ap.autocoh.bfrac = [0.2 0.2];
% ap.autocoh.t_scale = [6 7];
% ap.autocoh.tol = 1e-3;
% ap.autocoh.olap = 0.2;
% ap.autocoh.minbursts = 100;
% ap.autocoh.check_fit = false;

% %% Nourse Autocoherence analysis & simulation: CH8
% ap.autocoh.dt = 0.050;  % Width of the Gabor atom to use for transform
% ap.autocoh.blength = []; % Maximal burst length, set to [] for all lengths
% ap.autocoh.minlength = 0;
% ap.autocoh.use_cv = true; % Use the CV to determine burst autocoherence
% ap.autocoh.cv = 0.05; % Value to use id using CV for AC
% ap.autocoh.decorr_angle = pi/4;
% ap.autocoh.bsize = 1.5; % Burst size in Z-units
% ap.autocoh.useall = false;
% ap.autocoh.nsurr = 1;
% ap.autocoh.prob_bin = 5;
% ap.autocoh.prob_maxburstlength = .200;
% ap.autocoh.prob_minburstlength = 0;
% ap.autocoh.prob_caxis = [0 0.05];
% ap.autocoh.freq_add = [120];
% ap.autocoh.amp_scale = [2.65];
% %ap.autocoh.amp_scale = [2.5 2];
% ap.autocoh.bfrac = [0.2];
% ap.autocoh.t_scale = [16];
% ap.autocoh.tol = 1e-3;
% ap.autocoh.olap = -7.0;
% ap.autocoh.minbursts = 0;
% ap.autocoh.check_fit = false;

%% Nourse Autocoherence analysis & simulation: CH5
ap.autocoh.dt = 0.050;  % Width of the Gabor atom to use for transform
ap.autocoh.blength = []; % Maximal burst length, set to [] for all lengths
ap.autocoh.minlength = 0;
ap.autocoh.use_cv = true; % Use the CV to determine burst autocoherence
ap.autocoh.cv = 0.05; % Value to use id using CV for AC
ap.autocoh.decorr_angle = pi/4;
ap.autocoh.bsize = 1.5; % Burst size in Z-units
ap.autocoh.useall = false;
ap.autocoh.nsurr = 1;
ap.autocoh.prob_bin = 5;
ap.autocoh.prob_maxburstlength = .200;
ap.autocoh.prob_minburstlength = 0;
ap.autocoh.prob_caxis = [0 0.05];
ap.autocoh.freq_add = [120];
ap.autocoh.amp_scale = [1.8];
%ap.autocoh.amp_scale = [2.5 2];
ap.autocoh.bfrac = [0.2];
ap.autocoh.t_scale = [20];
ap.autocoh.tol = 1e-3;
ap.autocoh.olap = -8.0;
ap.autocoh.minbursts = 0;
ap.autocoh.check_fit = false;

ap.autocoh.periodic.nperm = 300;
ap.autocoh.periodic.frange = [125 165];
ap.autocoh.use_periodic = false;

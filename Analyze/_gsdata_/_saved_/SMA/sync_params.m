function [ap] = sync_params()

ap.condlist = {'aloud','rest_eo'};
%ap.condlist = {'rest_eo'};
ap.atype = 'corr';
ap.ptname = 'vant';
ap.usewt = 1;
ap.wnumber = 5;
ap.surr = 0;
ap.scramble_phase = 0;
ap.surr2ndcond = 0;
ap.freqs =  50:2.5:500;
ap.yaxis = [0 0.6];
ap.frange = [125 165];
ap.length = 60;
ap.alpha = 0.05;
ap.fdr_stringent = 1;


% Sync freq depedence surrogate analysis
ap.nsurrch = 12;  % Number of surrogate channels
ap.nsurr = 1; % Number of surrogates to run

ap.plotsync = 0;

% take abs of IC
ap.absic = 1;

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

% Frequency ranges of significance

if strcmp (ap.ptname, 'vant')
    ap.extrema_range(:,1) = [62 73];
    ap.extrema_range(:,2) = [92 107];
    ap.extrema_range(:,3) = [125 165];
    ap.extrema_range(:,4) = [200 400];
    ap.frange_names = {'g1', 'g2', 'g3', 'g4'};
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

% Phase - power correaltion
ap.ppc.nbins = 12;
ap.ppc.fremove = 10;
ap.ppc.threshold = 0;
ap.ppc.binrange = [-pi/3 pi/3];
ap.wind_length = 100; % in ms
ap.plags = -100:100; % in ms
ap.ppc.window = 5000;

% Instantaneous frequency and power relationship
ap.fpc.revrel = 0; % Shift the relationship to follow_amp and IEI
ap.fpc.amprange = [0 30];
ap.fpc.intrange = [0 20];


% PLOTTING
ap.pl.show_axes = 1;
ap.pl.colorbar = 1;
ap.pl.ranges = 1;
ap.pl.zeroline = 1;

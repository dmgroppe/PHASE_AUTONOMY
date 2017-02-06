function [ap] = sync_cc_params()

ap.condlist = {'aloud', 'quiet', 'rest_eo'};
%ap.condlist = {'rest_eo'};
ap.atype = 'pc';
ap.ptname = 'vant';
ap.usewt = 1;
ap.surr = 0;
ap.freqs = 2:2:50;
ap.yaxis = [0 1];
ap.frange = [125 165];
ap.length = 60;
ap.alpha = 0.05;

% Sync freq depedence surrogate analysis
ap.nsurrch = 12;  % Number of surrogate channels
ap.nsurr = 200; % Number of surrogates to run

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

% comment to add to tiltes etc
ap.comment = '';
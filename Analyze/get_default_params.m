function [params] = get_default_params()
            

%% Simulation parameters
%  Nesting
params.sim.nesting.k = 1;
params.sim.nesting.c = 1.0;
params.sim.nesting.tc = 2;
params.sim.nesting.highf = 120;
params.sim.nesting.lowf = 8;
params.sim.nesting.lowfamp = 1;
params.sim.nesting.noise_var = 0.1;
%params.sim.nesting.noise_var = 0.0;
params.sim.nesting.sr = 2500;
params.sim.nesting.npoints = 10000;
params.sim.nesting.invertrel = 1;
params.sim.nesting.pulse = 0;           % Use pulse in the simulation
params.sim.nesting.pulsestart = 200;    %Time to start pulse in ms
params.sim.nesting.pulsedur = 250;      % Duration of the pulse in ms
params.sim.nesting.niterations = 10;    % Duration of the pulse in ms
params.sim.nesting.nsubjects = 1;       % Number of subjects to simulate
params.sim.nesting.mod = 1;
%params.sim.nesting.tonic_highf = 0.001;
%params.sim.nesting.tonic_lowf = 0.05;
params.sim.nesting.tonic_highf = 0.000;
params.sim.nesting.tonic_lowf = 0.00;

%% Time-freq options
params.tf.scale_type = 'linear';
params.tf.fstart = 1;
params.tf.finc = 1;
params.tf.fend = 250;
params.tf.noctaves = 10;
params.tf.nvoices = 7;
params.tf.scale_start = 2;
params.tf.scramble_phase = 0;

%% Phase locking parameters
params.pl.bins = 60;
params.pl.probbins = 6;
params.pl.steps = 10;
params.pl.inclplcalcs = 1;
%% Wavelet 
params.wlt.bw = 5;

%% Data
params.data.srate = 500;
%% Analysis
params.ana.dataDir = '';
params.ana.dataFile = '';
params.ana.tagFile = '';
params.ana.epoch_list = [];
params.ana.chlist = [];
params.ana.append_data = 1;             % whether to add data to each end of the epoch
params.ana.ncycles_of_lowest = 2;       % Number of cycles of the lowest freq to include in analysis to each side
params.ana.baseline = 200;              % Baseline (in ms) to inlcude in the analysis
params.ana.exclude_invalid = 1;
%  If one does not truncate to the a specified length, then the epochs
%  get truncated to the shortest epoch, since any other type of analysis would
%  not allow appropriate averaging etc.
params.ana.fixed_length = 1;            % truncate all the epochs to 'length' below
params.ana.length = 600;                % Fix length to this amount of time
params.ana.exlude_marked = 0;           % exlude any marked epochs
params.ana.subjectname = '';
params.ana.test = 'encoding';
params.ana.cond = '';
params.ana.nepochs = 60;
params.ana.ch_analyzed = 0;
params.ana.epochs_analyzed = [];

params.ana.test = 'enc';
params.ana.cond1 = 'sH';
params.ana.cond2 = 'R';
params.ana.anat_loc = 'HP';
params.ana.analysis = 'comod';  % this can be 'tf' or 'comod' or 'ps'
params.ana.pschannels = {'HP'; 'EC'};   % Phase synchrony channels

%Bootstrapping
params.ana.nsurr = 2000;

%% Debug
params.debug.supress_analysis = 0;
params.debug.prompt = 0;
%% Display
params.disp.norm_to_baseline = 1;
params.display.cfm.fstart = 2;
params.display.cfm.fend = 14;

%% Export
params.export.export_results = 0;
params.export.prefix = '';
params.export.dir = 'D:\Projects\Data\Scene memory\TVA\Enc\';
params.export.figures = 1;

%% Triggers
params.trig.get_from_file = 0;
params.trig.dir = 'pos';
params.trig.offset = 1;             % in samples
params.trig.baseline = 100;         % in samples
params.trig.threshold = 2.5e6;
params.trig.min_trig_dur = 100;     % Trig duration in samples
params.trig.plot = '';

%% Statistics
params.stats.tbin_width = 100;      % Bin width in ms

%% Ridges
params.ridges.per = 50;             % Peaks that are smaller than 'per' of max peak
params.ridges.ncycles = 2;          % number of cycles of a given frequency to consider
                                    % a series of peaks to be a ridge

%% Debug
params.debug.prompts = 0;
params.debug.show = 0;
%% Sync options
params.sync.lowcut = 135;
params.sync.highcut = 145;
params.sync.ncycles = 5; % -1 if the whole length of data is to be used
params.sync.poverlap = 0.0;


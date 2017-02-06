function [cfg] = cfg_sim()

cfg.sim_type = 'osc'; % 'chirp', 'osc', 'noise'

cfg.nchan = 5;
cfg.noise_amp = 0.05;

cfg.chirp_amp = 0.01;
cfg.flat_freq = 0;

cfg.osc_freq = 30;
cfg.chirp_freq = [30 60];

cfg.chirp_start = 1;
cfg.chirp_length =13;

cfg.srate = 250;
cfg.sim_time = 15;
cfg.lvf_chan = 3;
cfg.noise_var = 20;

cfg.ext_noise = [];
cfg.diff_adaptive = true;
cfg.bigmem = true;

% Typical simualtion
cfg.chirp_amp = 0.2;
cfg.sim_type = 'osc';
%cfg.freqs = 6:0.5:100;
cfg.freqs = 6:1:100;
cfg.navg = 32;

% For doing simulation of noise amp and nchan 3D plots
%cfg.noise_amp = [0.001 0.01 0.025 0.05 0.075 0.1:0.05:1];
%cfg.nchan = 5:5:120;






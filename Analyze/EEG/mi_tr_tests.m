function [] = mi_tr_tests(ts, srate, events)

lfrange = [4 8];

simp = get_default_sim_params();
simp.sim.nesting.sr = srate;

% Set the length of the time window for simulation
spoints = 2000;
nevents = length(events);
simp.sim.nesting.npoints = spoints;

% PUlse charateristics
simp.sim.nesting.pulse = 1;
simp.sim.nesting.pulsestart = 200;
simp.sim.nesting.pulsedur = 100;

% Amplitudes and time constants of oscillations
simp.sim.nesting.highf = 140;
simp.sim.nesting.lowf = mean(lfrange);
simp.sim.nesting.lowfamp = 0.05;
  % High freq amplitude
simp.sim.nesting.k = 0.05;
simp.sim.nesting.c = 1;
simp.sim.nesting.tc = 1;

% Phase variance of low frequency oscillation - this determines if
% phase-resetting is simulated 0 = phase resetting
simp.sim.nesting.phase_var = 0;

% Noise variance
simp.sim.nesting.noise_var = 0.1;

% Toggle nesting
simp.sim.nesting.nest = true;

% Generate completely synthetic oscillations
simp.sim.nesting.gen_low_osc = 1;

% Scaling of the time series
simp.sim.nesting.ts_scale = 1;

% selects peak or trough nesting
simp.sim.nesting.invertrel = 1;

% Value in Hz above which to use for addition of noise
simp.sim.nesting.noise_cutoff = 0;

%test_param = 1:4:32;
test_param = 0.5;

hfrange = [60 200];


R = sim_tr_nesting(ts, events, srate, lfrange, simp);
figure(10); plot(R.nested);drawnow;
mi = pac_tr(R.nested, srate, [-200 600], 4:30, hfrange, events, true);



% figure(1);
% clf;
% plot(hg_amps, testp);
% axis([hg_amps(1) hg_amps(end) min(testp) max(testp)]);
% xlabel('High gamma amplitude (\muV)');
% ylabel('CFC');
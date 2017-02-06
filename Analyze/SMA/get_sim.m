function [x, low_osc, high_mod, noise] = get_sim(npoints, lowf, highf, srate)

params = get_default_params();
params.sim.nesting.npoints = npoints;

params.sim.nesting.highf = mean(highf);
params.sim.nesting.lowf = mean(lowf);
params.sim.nesting.sr = srate;
params.sim.nesting.k = 1;
params.sim.nesting.c = 1;
params.sim.nesting.lowfamp = 1;
params.sim.nesting.noise_var = 0;

[x, low_osc, high_mod, noise] = sim_nesting(params);
%plot(x(1:fix(10/params.sim.nesting.lowf*srate)));
function [nested, high_mod, noise] = eeg_sim_nesting(ts, srate, frange, params)
% [nested] = sim_nesting(params)
% Generates nested oscillations

low_osc = eegfilt(ts, srate, frange(1), frange(2));

%low_osc = sin_wave(params.sim.nesting.lowf, params.sim.nesting.npoints, params.sim.nesting.sr, 0);
high_osc = sin_wave(params.sim.nesting.highf, params.sim.nesting.npoints, params.sim.nesting.sr, 0);
noise = (0.5-rand(1,params.sim.nesting.npoints))*params.sim.nesting.noise_var;

if (params.sim.nesting.invertrel == 1)
    sign = -1;
else
    sign = 1;
end

x = params.sim.nesting.k./(1+exp(-params.sim.nesting.c*(sign*low_osc-params.sim.nesting.tc)));
high_mod = high_osc.*x;

if (params.sim.nesting.pulse)
    start = TimeToSamples(params.sim.nesting.pulsestart, params.sim.nesting.sr);
    dur = TimeToSamples(params.sim.nesting.pulsedur, params.sim.nesting.sr);
    p = pulse(params.sim.nesting.npoints, start, dur);
else
    p = 1;
end

% Scale for ampitude after the high osc is computed
low_osc = params.sim.nesting.lowfamp*low_osc;

tonic_osc = params.sim.nesting.tonic_highf*high_osc + params.sim.nesting.tonic_lowf*low_osc;

%nested = noise + p.*(low_osc + high_mod) + tonic_osc;
nested = noise + low_osc + p.*high_mod + tonic_osc;

nested = nested - mean(nested);
x = get_x(params.sim.nesting.npoints, params.sim.nesting.sr);
%plot(x, low_osc, x, high_mod, x, nested);

%[noisemean, noisevar] = ts_stats(noise);
%highfamp = (max(high_mod) - min(high_mod))/2;

%display(sprintf('Noise var = %6.1f, lowf amp = %6.1f, highf amp = %6.1f',noisevar, params.sim.nesting.lowfamp, highfamp));







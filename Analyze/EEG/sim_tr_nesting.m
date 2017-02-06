function [R] = sim_tr_nesting(ts, events, srate, lfrange, simp)

spoints = 2000;
nevents = length(events);

if nargin < 5 
    simp = get_default_sim_params();

    simp.sim.nesting.sr = srate;

    % Set the length of the time window for simulation
    simp.sim.nesting.npoints = spoints;

    % PUlse charateristics
    simp.sim.nesting.pulse = 1;
    simp.sim.nesting.pulsestart = 100;
    simp.sim.nesting.pulsedur = 200;

    % Amplitudes and time constants of oscillations
    simp.sim.nesting.highf = 140;
    simp.sim.nesting.lowf = mean(lfrange);
    simp.sim.nesting.lowfamp = 1.0;
      % High freq amplitude
    simp.sim.nesting.k = 0.1;
    simp.sim.nesting.c = 1;
    simp.sim.nesting.tc = 1;

    % Phase variance of low frequency oscillation
    simp.sim.nesting.phase_var = 0;

    % Noise variance
    simp.sim.nesting.noise_var = 1;

    % Toggle nesting
    simp.sim.nesting.nest = true;

    % Generate completely synthetic oscillations
    simp.sim.nesting.gen_low_osc = true;
    
    % Scaling of the time series
    simp.sim.nesting.ts_scale = 5;
 
end

ts = ts*simp.sim.nesting.ts_scale;

% If using time series then filter and get low freq oscillation
if ~simp.sim.nesting.gen_low_osc
    d = window_FIR(lfrange(1), lfrange(2), srate);
    R.low_osc = filtfilt(d.Numerator, 1, ts);
    lf_h = hilbert(R.low_osc);
    lf_angle = angle(lf_h);
else
    R.low_osc = zeros(1,length(ts));
end

nested = ts;
R.nested = nested;
R.nested = (0.5-rand(1,length(R.nested)))*simp.sim.nesting.noise_var;

pulses = zeros(1,length(ts));
R.pulses = pulses;

R.cv = zeros(1,spoints);
pl_mat = pl_matrix(1, spoints, 60);

for i=1:nevents
    [high_mod, low_osc] = nest(simp, ts, R.low_osc, events(i));
    ev_start = events(i);
    ev_end = events(i) + spoints -1;
    R.pulses(ev_start:ev_end) = pulses(ev_start:ev_end) + high_mod;  
    
    % Add the midulated high frequency signal to the original signal
    if simp.sim.nesting.gen_low_osc
        yi = interp1([1 spoints],[R.nested(ev_start)  R.nested(ev_end)],1:spoints);
        R.nested(ev_start:ev_end) = R.nested(ev_start:ev_end)+ (high_mod + low_osc)+yi;
        R.low_epochs(:,i) = low_osc;
    else
        R.nested(ev_start:ev_end) = R.nested(ev_start:ev_end) + nested(ev_start:ev_end) + high_mod;
        R.low_epochs(:,i) = R.low_osc(ev_start:ev_end);
    end
    
    R.high_epochs(:,i) = high_mod;
    
    if ~simp.sim.nesting.gen_low_osc
        R.cv = R.cv + exp(1i*lf_angle(ev_start:ev_end));
        pl_mat = set_pl_matrix(pl_mat,lf_h(ev_start:ev_end)); 
    end
end

if ~simp.sim.nesting.gen_low_osc
    R.cv = abs(R.cv)/nevents;
    R.pl = get_pl_stats(pl_mat, 6, 10);
end

function [high_mod, low_osc noise] = nest(params, ts, low_freq_osc, event)

spoints = params.sim.nesting.npoints;
ev_start = event;
ev_end = event + spoints -1;

phase_var = params.sim.nesting.phase_var*randn(1)*pi;

high_osc = sin_wave(params.sim.nesting.highf, params.sim.nesting.npoints, params.sim.nesting.sr, 0);
% if ~params.sim.nesting.noise_cutoff
%     
% else
%     b = fir1(100,params.sim.nesting.noise_cutoff/params.sim.nesting.sr/2,'high',chebwin(101,30));
%     noise = filter(b,1,ts(1:2*params.sim.nesting.npoints));
%     noise = noise(params.sim.nesting.npoints/4:(params.sim.nesting.npoints/4+params.sim.nesting.npoints-1));
% end

if params.sim.nesting.gen_low_osc
    low_osc = sin_wave(params.sim.nesting.lowf, params.sim.nesting.npoints, params.sim.nesting.sr, phase_var);
else
    low_osc = low_freq_osc(ev_start:ev_end);
end

low_osc_std = std(low_osc);
low_osc = (low_osc-mean(low_osc))/low_osc_std;

if (params.sim.nesting.invertrel == 1)
    sign = -1;
else
    sign = 1;
end

x = params.sim.nesting.k./(1+exp(-params.sim.nesting.c*(sign*low_osc-params.sim.nesting.tc)));

if params.sim.nesting.nest
    high_mod = high_osc.*x;
else
    high_mod = high_osc;
end

low_osc = low_osc*params.sim.nesting.lowfamp;


if (params.sim.nesting.pulse)
    start = TimeToSamples(params.sim.nesting.pulsestart, params.sim.nesting.sr);
    dur = TimeToSamples(params.sim.nesting.pulsedur, params.sim.nesting.sr);
    p = pulse(params.sim.nesting.npoints, start, dur);
else
    p = 1;
end

high_mod = high_mod.*p;

if params.sim.nesting.gen_low_osc
    low_osc = low_osc.*hann(spoints)';
else
    low_osc = low_osc*low_osc_std;
end




    






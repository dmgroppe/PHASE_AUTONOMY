function [] = test_twt(inc)

params = get_default_params();

niterations = params.sim.nesting.niterations;
sr = params.sim.nesting.sr;
params.pl.inclplcalcs = 0;

if (strcmp(params.tf.scale_type,'linear'))
    scales = linear_scale(params.tf.fstart:params.tf.finc:params.tf.fend,params.sim.nesting.sr);
else
    scales = log_scale(params.tf.scale_start, params.tf.noctaves, params.tf.nvoices);
end

msavg=zeros(length(scales), length(scales));
mpavg=zeros(length(scales), length(scales));
ms = zeros(length(scales), length(scales));
wt = zeros(length(scales), params.sim.nesting.npoints, niterations);

% Allocate the PL matrix
pl = pl_matrix(length(scales), params.sim.nesting.npoints,params.pl.bins);

% Get the x axis values
x = get_x(params.sim.nesting.npoints, sr);

vars = zeros(niterations, 3);
for s=1:params.sim.nesting.nsubjects
    sprintf('Subject %d',s)
    for i=1:niterations
        display(sprintf('MP: Iteration %d of %d',i, niterations));
        [d, low_osc, high_mod, noise] = sim_nesting(params);
        vars(i,:) = [var(low_osc); var(high_mod); var(noise)];
        %[m,st] = ts_stats(d)
        [wt(:,:,i) frq] = twt(d, params.sim.nesting.sr, scales, params.wlt.bw);
        mpavg = mpavg + mod_phase(wt(:,:,i));
    end

    %mpavg = mpavg/niterations;

    for i=1:niterations
        display(sprintf('MS: Iteration %d of %d',i, niterations));
        msavg = msavg + mod_strength(wt(:,:,i),mpavg);
    end
    ms = ms + msavg/niterations;
end

% Average over all the subjects
ms = ms/params.sim.nesting.nsubjects;


clear('msavg', 'mpavg');


if (params.pl.inclplcalcs)
    h = figure(1);
    set(h, 'Name', 'PL');
    display('Computing PL statistics...');
    for i=1:niterations
        pl = set_pl_matrix(pl, wt(:,:,i));
    end
    pl_stats = get_pl_stats(pl, params.pl.probbins, params.pl.steps);
    clear('pl');
    surf(x, frq, pl_stats);
    view(0,90);
    shading interp;
end

h = figure(2);
set(h, 'Name', 'CVAR');
cvar = mean(wt, 3);
surf(x, frq, abs(cvar));
view(0,90);
shading interp;


[wt,frq] = twt(d, params.sim.nesting.sr, scales, params.wlt.bw);
ns = norm_scalogram(wt, scales);

lfstart = GetIndex(frq, 2);
lfend = GetIndex(frq, 14);

h = figure(3);
set(h, 'Name', 'MS');
surf(frq(lfstart:lfend), frq(lfend:end), ms(lfend:end, lfstart:lfend));
axis([frq(lfstart), frq(lfend), frq(lfend), frq(end) min(min(ms(lfend:end, lfstart:lfend))) max(max(ms(lfend:end, lfstart:lfend)))]);
view(0,90);
shading interp;
title('Mod strength');

h = figure(4);
set(h, 'Name', 'Scalogram');
dplot = ns;
%dplot = abs(wt);
zmax = max(max(dplot));
zmin = min(min(dplot));
surf(x, frq, dplot);
axis([min(x) max(x) frq(1), frq(end) zmin zmax]);
view(0,90);
shading interp;

h = figure(5);
set(h, 'Name', 'Data');
plot(x,d, x, low_osc, x, high_mod, x, noise);
lfv = mean(vars(:,1));
display(sprintf('high var = %4.2e, noise var = %4.2e', mean(vars(:,2))/lfv, mean(vars(:,3))/lfv));


%{

n = params.sim.nesting.npoints;
dt = .1;
%time = [0:length(sst)-1]*dt + 1871.0 ;  % construct time array
%xlim = [1870,2000];  % plotting range
pad = 1;      % pad the time series with zeroes (recommended)
dj = 0.25;    % this will do 4 sub-octaves per octave
s0 = 2*dt;    % this says start at a scale of 6 months
j1 = 7/dj;    % this says do 7 powers-of-two with dj sub-octaves each
lag1 = 0.72;  % lag-1 autocorrelation for red noise background
mother = 'Morlet';

%[wave,period,scale, coi] = wavelet(d,dt,pad,dj,s0,j1,mother);
[wave,period,coi] = wavelet(d,dt, pad, 1:300);
power = (abs(wave)).^2 ;        % compute wavelet power spectrum

figure(5);
surf(x, period, power);
shading interp
view(0,90);
%}

%{
figure(2);
surf(angle(mp));
view(0,90);
shading interp;
title('Modulation phase');


figure(3)
surf(x, frq, abs(wt));
view(0,90);
shading interp;
title('Spectogram');


figure(4)
[mi] = mod_strength(wt);
surf(frq, frq, angle(ms));
view(0,90);
shading interp;
title('Mod angle');
%}

%figure(5);
%mnorm(d, sr)
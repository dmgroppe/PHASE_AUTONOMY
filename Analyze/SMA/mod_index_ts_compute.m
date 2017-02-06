function [] = mod_index_ts_compute(x, srate, lowf, highf, dosim)

if nargin < 5; dosim = 0; end;

nbin = 36;
nsurr = 200;

if dosim
    x = get_sim(length(x), lowf, highf, srate);
end

d = window_FIR(lowf(1), lowf(2), srate);
hlow = hilbert(filtfilt(d.Numerator, 1, x));

d = window_FIR(highf(1), highf(2), srate);
hhigh = hilbert(filtfilt(d.Numerator, 1, x));

comp(1,:) =  angle(hlow);
comp(2,:) = abs(hhigh);

[P, Q, KLD, phi] = mod_index(comp, nbin);
figure(1);
plot_amp_histo(P, phi);

fprintf('MI = %e\n', KLD);
[klds] = get_surr(comp, nsurr, nbin);
p = (1+sum(klds > KLD))/nsurr;
fprintf('p = %e\n', p);


d = window_FIR(lowf(1), lowf(2), srate);
hlow = hilbert(filtfilt(d.Numerator, 1, abs(hhigh)));

comp(1,:) =  angle(hlow);
comp(2,:) = abs(hhigh);

[P, Q, KLD, phi] = mod_index(comp, nbin);
fprintf('MI of high amp envelope = %e\n', KLD);
figure(2);
plot_amp_histo(P, phi);

[klds] = get_surr(comp, nsurr, nbin);
p = (1+sum(klds > KLD))/nsurr;
fprintf('p = %e\n', p);

figure(3);
scatter(angle(hhigh), abs(hhigh));

function [x] = get_sim(npoints, lowf, highf, srate)

params = get_default_params();
params.sim.nesting.npoints = npoints;

params.sim.nesting.highf = mean(highf);
params.sim.nesting.lowf = mean(lowf);
params.sim.nesting.sr = srate;
params.sim.nesting.k = 0.01;
params.sim.nesting.noise_var = 0.0;

[x, ~, ~, ~] = sim_nesting(params);
plot(x(1:fix(10/params.sim.nesting.lowf*srate)));

function [klds] = get_surr(comp, nsurr, nbin)

npoints = length(comp);

klds = zeros(1, nsurr);

newcomp = comp;
for i=1:nsurr
    sshift = fix(0.5*rand*npoints)+1;
    newcomp(1,:) = [comp(1,sshift:end) comp(1, 1:sshift-1)];
    [~, ~, klds(i), ~] = mod_index(newcomp, nbin);
end

function [] = plot_amp_histo(P, phi)

plot(phi, P);
xlabel('Low f phase');
ylabel('High f amp');
axis([-pi pi min(P) max(P)]);

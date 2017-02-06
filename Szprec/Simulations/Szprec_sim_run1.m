function [R] = Szprec_sim_run1(cfg, scfg)

global DATA_PATH;

if nargin <1; cfg = cfg_default();end
if nargin < 2; scfg = cfg_sim(); end;

% Load up real baseline signal for background

sim_path = fullfile(DATA_PATH,'Szprec\Sim', 'Sim_data.mat');
if exist(sim_path, 'file') && ~isempty(scfg.ext_noise)
    display('Using external noise file for simulations...')
    load(sim_path);
else
    sim_data = [];
end

for i = 1:length(scfg.freqs)
    cfgs(i) = scfg;
    cfgs(i).osc_freq = scfg.freqs(i);
end

nsim = length(cfgs);

for i=1:nsim
    scfg = cfgs(i);
    scfg.ext_noise = sim_data;
    tic
    display(sprintf('Working on sim %d of %d.', i, nsim));
    [r(:,i),nr(:,i) raw(:,i)] = run_sim(scfg, cfg);
    toc
end


% figure(10);clf;
% surface(noise_amp, nchan, squeeze(mean(r,1))');
% view(0,90);
% shading interp;

R = struct_from_list('cfgs', cfgs, 'r', r, 'nr', nr, 'raw', raw, 'scfg', scfg);

function [r nr raw] = run_sim(scfg, cfg)

r = zeros(1,scfg.navg);
nr = r;
raw = nr;

for i=1:scfg.navg
    [r(i),nr(i), raw(i)] = Szprec_simulation1(scfg, cfg, 0);
end
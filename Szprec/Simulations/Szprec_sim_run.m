function [R] = Szprec_sim_run()

noise_amp = [0.001 0.01 0.025 0.05 0.075 0.1:0.05:1];
nchan = 5;

%noise_amp = [0.0001 0.001 0.01 0.1];
%nchan = 5:5:15;

n_avg = 1;
make_gamma = false;
flat_freq = 0;

tic
r = [];
nr = [];
for c=1:length(nchan)
    display(sprintf('Working on %d channel sim.', nchan(c)));
    tic
    [r(:,:,c),nr(:,:,c)] = run_sim(nchan(c), noise_amp, n_avg, make_gamma, flat_freq);
    toc
end
toc

% figure(10);clf;
% surface(noise_amp, nchan, squeeze(mean(r,1))');
% view(0,90);
% shading interp;

R = struct_from_list('n_avg', n_avg, 'make_gamma', make_gamma, 'nchan', nchan, 'flat_freq',...
    flat_freq, 'r', r, 'nr', nr, 'noise_amp', noise_amp);

save('D:\Projects\Data\Szprec\R_noise_sim.mat', 'R');

function [r nr] = run_sim(nchan, noise_amp, n_avg, make_gamma, flat_freq)

r = zeros(n_avg, length(noise_amp));
nr = r;

parfor i=1:length(noise_amp)
    for j=1:n_avg
        [r(j,i),nr(j,i)] = Szprec_simulation(make_gamma, nchan, noise_amp(i), flat_freq, 0);
    end
end
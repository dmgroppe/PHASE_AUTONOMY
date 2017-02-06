function [] = gm()

freqs = 6:0.5:100;
nsim = 100;
srate = 500;
sim_time = 5;
npoints = srate*sim_time;

scfg = cfg_sim();
cfg = cfg_default();

for i=1:nsim
        noise = SimulateOrnsteinUhlenbeck(0, 0, .01, 0, 1/srate, npoints)*scfg.cfg.noise_var;
        osc = sin_wave(freqs(i), npoints,srate, rand*2*pi);
        wt_noise = twt(noise,srate,linear_scale(freqs,srate));
        wt_osc = twt(osc,srate,linear_scale(freqs,srate));
    end
end


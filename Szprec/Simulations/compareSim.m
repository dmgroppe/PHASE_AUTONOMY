function [R1 R2] = compareSim()

scfg = cfg_sim();

cfg = cfg_default();
cfg.useFilterBank = true; % Us the hilbert method

cfg.diff_adaptive = true;
cfg.diff_adaptive_rads = pi;

[R1] = Szprec_sim_run1(cfg, scfg);


cfg.diff_adaptive = false;
R2 = Szprec_sim_run1(cfg, scfg);
R_plot(R1, R2)


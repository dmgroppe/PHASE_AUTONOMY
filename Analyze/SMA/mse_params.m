function [p] = mse_params()

p.m_max = 2;
p.m_min = 2;
p.m_step = 1;
p.r_max = 0.15;
p.r_min = 0.15;
p.r_step = .05;
p.scale_max = 40;
p.scale_step = 1;
p.slength = 60;
p.sim = 0;
p.simfreq = 140;

p.what = 'raw';
p.condlist = {'aloud', 'quiet', 'rest_eo', 'rest_ec'};
p.ptname = 'vant';

p.srange = [1 5];
p.plateau = [p.scale_max-20 p.scale_max];
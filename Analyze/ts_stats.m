function [smean, svar] = ts_stats(sim_d)

smean = mean(sim_d);
svar = std(sim_d);
% USAGE: [samples] = time_to_samples(time, sr)

function [samples] = time_to_samples(time, sr)

samples = fix(sr/1000.0*time);
%  USAGE: [alimits] = truncate_to(alimits, trunc_samples)
%
%   Truncates the analysis to the truc_time
%   INPUT:
%       alimits:        Cell of limits
%       truc_samples:   samples to truncate to epoch to

function [alimits] = truncate_to(alimits, trunc_samples)

nepochs = length(alimits);

for i=1:nepochs
    alimits{i}.ep_end = alimits{i}.ep_start + trunc_samples;
end
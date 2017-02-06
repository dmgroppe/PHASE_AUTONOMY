% USAGE: alimits] = add_baseline(alimits, baseline_samples)
%
%   Inputs:
%       alimits:            Cell of limits
%       baseline_samples:   number of samples to offset beginning of the
%                           epoch 

function [alimits] = add_baseline(alimits, baseline_samples)

nepochs = length(alimits);

for i=1:nepochs
    % Make sure you don't go negative
    if ((alimits{i}.ep_start - alimits{i}.prefix - baseline_samples) <= 0)
        alimits{i}.prefix = alimits{i}.prefix-baseline_samples-1;
    end
    % baseline is added by subtracting the baseline samples from the epoch
    % onset index
    alimits{i}.ep_start = alimits{i}.ep_start - baseline_samples;
end
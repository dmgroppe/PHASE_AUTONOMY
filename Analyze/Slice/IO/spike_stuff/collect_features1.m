function [F, S, SR] = collect_features1(R, ap)
% Collects the various features of spikes in epochs and organizes them into
%
% USAGE: [F, S, SR] = collect_features(R)
%
% Input R (structure with field obtained from slice_io.m
%   R.spikes = raw traces of the spikes
%   R.S = cell array of spike times etc for spikes in each epoch
%   R..mp = various membrane parameters
% Output:
%   F = cell array of features
%   S = cell array of spikes
%   SR = cell array of sampling rates - (needed to reconstruct the time
%       series

if nargin < 2; ap = sl_sync_params(); end;

cfg.troughalign = 0;
cfg.interpn = 2;
cfg.normalize = 0;
cfg.fsample = R(1).S.sr;

% Interate over each epoch
for e=1:numel(R.spikes)        
    % Interate over each spike
    count = 0;
    if min(size(R.spikes{e}))
        % Put all the spikes in a Matrix
        for s = 1:min(size(R.spikes{e}))
            count = count + 1;
            [W, X, par] = spikewaveformparameter_03(cfg,R.spikes{e}(s,:));
            F{e}{count} = par(s,:);
            S{e}{count} = W(s,:);
            SR{e}{count} = R.S.sr; % Keep the sampling rate so can plot each spike properly
        end
    end
end
    

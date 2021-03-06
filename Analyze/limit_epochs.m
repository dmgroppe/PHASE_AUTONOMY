% USAGE:  [epoch_limits] = limit_epochs(epochs, params, sr, max_samples)
%   
%   Input:  epochs:         Cell of epochs to analyze
%           params:         Analysis parameters
%           sr:             Sampling rate
%           max_samples:    Total number of samples in the data to analyze
%
%--------------------------------------------------------------------------

function [epoch_limits] = limit_epochs(epochs, params, sr, max_samples)

% limits:   contains the as the first two elements as the beginning and end of
%           the epoch, and the third and fourth values are amount of data to place on either
%           side of the epoch

alimit.ch = 0;
alimit.ep = 0;
alimit.ep_start = 0;
alimit.ep_end = 0;
alimit.prefix = 0;
alimit.suffix = 0;

nepochs = length(epochs);
epoch_limits = cell(1,nepochs);

for i=1:nepochs
   
    alimit.ep = epochs{i}.ep;
    alimit.ch = epochs{i}.ch;
    alimit.ep_start = time_to_samples(epochs{i}.limits(1), sr);
    alimit.ep_end = time_to_samples(epochs{i}.limits(2), sr);

    % if using a fixed length set the end appropriately
    if (params.ana.fixed_length)
        alimit.ep_end = alimit.ep_start + time_to_samples(params.ana.length, sr);
    end

    % if no appending of data
    if (~params.ana.append_data)   
        alimit.prefix = 0;
        alimit.suffix  = 0;
        return
    end

    % compute the number of points to append to the data
    max_scale = max(get_scales(params, sr));
    npad_samples = max_scale*params.ana.ncycles_of_lowest;

    % check to see if there is under-run
    if ((alimit.ep_start - npad_samples) < 1)
        alimit.prefix = alimit.ep_start-1;
    else
        alimit.prefix = npad_samples;
    end

    % check to see if there is overrun-run
    if ((alimit.ep_end + npad_samples) > max_samples)
        alimit.suffix = max_samples-(alimit.ep_end-1);
    else
        alimit.suffix = npad_samples;
    end
    
    epoch_limits{i} = alimit;
end

    



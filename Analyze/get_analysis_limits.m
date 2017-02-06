function [alimit] = get_analysis_limits(ep_tag, params, sr, max_samples)

% limits:   contains the as the first two elements as the beginning and end of
%           the epoch, and the third and fourth values are amount of data to place on either
%           side of the epoch

alimit.ep_start = time_to_samples(ep_tag.limits(1), sr);
alimit.ep_end = time_to_samples(ep_tag.limits(2), sr);
alimit.ep = ep_tag.ep;
alimit.ch = ep_tag.ch;


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

    



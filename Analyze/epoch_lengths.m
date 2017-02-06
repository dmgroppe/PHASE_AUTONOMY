%USAGE: [shortest, longest] = epoch_lengths(epochs)
%   Input:
%       epochs:     Cell array of epochs
%   Output:
%       shortest, longest: in ms (not samples)
%---------------------------------------------------------

function [shortest longest] = epoch_lengths(epochs)


nepochs = length(epochs);

longest = -1e6;
shortest = 1e6;
for i=1:nepochs
    ep_length = epochs{i}.limits(2) - epochs{i}.limits(1);
    if (ep_length > longest)
        longest = ep_length;
    end
    
    if (ep_length < shortest)
        shortest = ep_length;
    end
end
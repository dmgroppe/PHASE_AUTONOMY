% USAGE: [epoch_tag] = get_epoch_tag(tags, ep)
%   Gets tag structure of specified epoch within tag cell
%   INPUT:
%       tags:       Cell of tagsparameter structure
%       ep:         Epoch number of requested tag
%   OUTPUT:
%       empty structure if not found
%
%------------------------------------------------------------------

function [epoch_tag] = get_epoch_tag(tags, ep)
epoch_tag = [];

for i=1:length(tags)
    if (tags{i}.ep == ep)
        epoch_tag = tags{i};
        return;
    end
end
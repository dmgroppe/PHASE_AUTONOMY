%USAGE: [epochs] = collect_epochs(tags, params, channel)
%
%   Input:
%   tags:       cell of tags
%   params:     analysis parameters
%   channel:    channel number from which to collect epochs
%
%--------------------------------------------------------------------------

function [epochs] = collect_epochs(tags, params, channel)

% get the tags for this channel only
 ch_tags = get_ch_tags(tags, channel);

% Initialize some of the counters and matricies
nepochs = length(params.ana.epoch_list);
total_epochs = 0;
epochs = [];

for j=1:nepochs
    include = 1;
    epoch_n = params.ana.epoch_list(j);
    epoch_tag = get_epoch_tag(ch_tags,epoch_n);
    %display(sprintf('Epoch#%d: %6.0fms to %6.0fms', epoch_n, epoch_tag.limits(1), epoch_tag.limits(2)));
    if (epoch_tag.valid )
        display(sprintf('Epoch %d is valid.', epoch_n));
        if (epoch_tag.markers(1))
            display(sprintf('  Marked at %5.0f ms', epoch_tag.markers(1)));
            if (params.ana.exlude_marked)
                include = 0;
            end
        end
    else
        display(sprintf('Epoch %d is NOT valid', epoch_n));
        if (params.ana.exclude_invalid)
            include = 0;
        end
    end
    if (include)
        total_epochs = total_epochs + 1;
        % Store the valid epochs
        epochs{total_epochs} = epoch_tag;
    else
        display('  This epoch will NOT be included.')
    end
end

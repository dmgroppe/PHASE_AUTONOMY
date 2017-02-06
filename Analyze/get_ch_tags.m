% USAGE: [ch_tags] = get_ch_tags(tags, ch)
%   Input:
%       tags:       cell of tags
%       ch:         channel number
%   Output:
%        ch_tags:   list of channel tags associated with 'ch'


function [ch_tags] = get_ch_tags(tags, ch)


ntags = length(tags);
ch_tags = [];

ncount = 0;
for i=1:ntags
    if (tags{i}.ch == ch)
        ncount = ncount + 1;
        ch_tags{ncount} = tags{i};
    end
end
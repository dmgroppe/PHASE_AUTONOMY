function [bi_names, bi_numbers] = bipolar_labels(group_end_index, mono_labels)

% Function to take channels names and derive bipolar names and channel
% indicies

nchannels = group_end_index(end);

if nargin < 2
    for i=1:nchannels
        mono_labels{i} = sprintf('CH_%03d', i);
    end
end

sind = circshift(1:nchannels, [0 -1]);

count = 0;
for i=1:nchannels
    if ~sum(group_end_index == i)
        count = count + 1;
        bi_names{count} = sprintf('%s-%s', mono_labels{i}, mono_labels{sind(i)});
    end
end

bi_numbers = [(1:nchannels)', sind'];
bi_numbers(group_end_index,:) = [];
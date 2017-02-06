function [] = make_channel_info(pt_name, group_end_index, nchan, varargin)

global DATA_PATH;

ch_file = sprintf('\\Szprec\\%s\\%s_channel_info.mat', pt_name, pt_name);
fname = fullfile(DATA_PATH, ch_file);

if mod(numel(varargin),2)
    display('Incomplete argument list for channel labels');
    return;
end

if isempty(group_end_index)
    group_end_index = [];
    for i=2:2:numel(varargin)
        group_end_index = [group_end_index varargin{i}];
    end
    group_end_index = cumsum(group_end_index);
end

if group_end_index(end) ~= nchan
    display('Total channels do not correspond');
    return;
end

m_labels = mono_labels(varargin);

if numel(m_labels) ~= group_end_index(end)
    error('Mismatch between number of monopolar channels and group_end_index');
end

[bi_labels, bi_numbers] = bipolar_labels(group_end_index, m_labels);

save(fname, 'bi_labels', 'bi_numbers', 'm_labels', 'group_end_index');



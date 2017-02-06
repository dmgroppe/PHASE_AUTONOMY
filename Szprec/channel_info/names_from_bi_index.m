function [R] = names_from_bi_index(bi_index, pt_name)

% USAGE: [ch_name, indicies] = names_from_bi_index(bi_index, pt_name)

% Returns the channel labels for a specified bipolar channel

global DATA_DIR;

% DG change
ch_file = sprintf('%s_channel_info.mat', pt_name);
fname = fullfile(DATA_DIR,'Szprec',pt_name,ch_file);
%global DATA_PATH;
% ch_file = sprintf('\\Szprec\\%s\\%s_channel_info.mat', pt_name, pt_name);
% fname = fullfile(DATA_PATH, ch_file);

if ~exist(fname, 'file')
    display('File does not exits');
    display(fname);
    R = [];
    return;
end

load(fname);
R.bi_labels = bi_labels;
R.bi_chlabel = bi_labels{bi_index};

R.bi_ind = bi_numbers(bi_index,:);
R.m_labels = m_labels;
R.group_end_index = group_end_index;
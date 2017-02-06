function [bi_numbers] = get_bi_numbers(pt_name)
global DATA_DIR;

fname = sprintf('%s_channel_info.mat', upper(pt_name));
ch_info = fullfile(DATA_DIR, 'Szprec', pt_name, fname);
load(ch_info);
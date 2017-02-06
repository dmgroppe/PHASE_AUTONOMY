function [bad_m_channels, bad_b_channels] = bad_channels_get(pt_name)

global DATA_DIR;
% DG change
ch_file = sprintf('%s_channel_info.mat', pt_name);
fname = fullfile(DATA_DIR,'Szprec',pt_name,ch_file);
% global DATA_PATH;
% ch_file = sprintf('\\Szprec\\%s\\%s_channel_info.mat', pt_name, pt_name);
% fname = fullfile(DATA_PATH, ch_file);

if ~exist(fname, 'file')
    display('Chanel info file does not exist');
    bad_m_channels = [];
    bad_b_channels = [];
    return;
end

load(fname);

if ~exist('bad_m_channels', 'var')
    bad_m_channels = [];
    bad_b_channels = [];
end
    

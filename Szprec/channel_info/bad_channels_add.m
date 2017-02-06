function [] = bad_channels_add(pt_name, bad_m_channels, bad_b_channels)

global DATA_PATH;

ch_file = sprintf('\\Szprec\\%s\\%s_channel_info.mat', pt_name, pt_name);
fname = fullfile(DATA_PATH, ch_file);

if ~exist(fname, 'file')
    display('Channel info file does not exist');
    return;
end

save(fname, 'bad_m_channels', 'bad_b_channels', '-append');

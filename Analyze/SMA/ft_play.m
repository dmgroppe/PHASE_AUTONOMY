function [dat hdr] = ft_play()

filename = 'D:\Projects\Data\Vant\Resting state and Reading.CNT';

hdr = ft_read_header(filename);
dat = ft_read_data(filename, 'dataformat', 'ns_cnt32');
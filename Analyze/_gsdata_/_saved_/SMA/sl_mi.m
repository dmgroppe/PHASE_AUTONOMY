function [] = sl_mi(data)

old_sr = 10000;
new_sr = 2000;

trange = [13.7*60 14.69*60];

[seg, T] = get_segment(nesting, 2, trange);
[xdec, new_rate] = sl_filter_resample(seg, [0.001 new_sr/2], old_sr, new_sr);
sl_mi_grid(xdec, new_sr, 2:30, 30:2:200, 2000,0);
function [sz_times] = szTimesMark(pt_name)

sz_names = data_filenames(pt_name);
close all;

display('Mark times in order as 1) start, 2) end, and  3) center.');

for i=1:numel(sz_names)
    ad_path = make_data_path(sz_names{i}, 'fig');
    uiopen(ad_path,1);
    t = ginput(3);
    sz_times(i).name = sz_names{i};
    sz_times(i).times = t;
    close;
end
save(make_data_path(pt_name, 'sz_times'), 'sz_times');
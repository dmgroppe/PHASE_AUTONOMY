function [nestdata] = sl_load_midata()
load('D:\Projects\Data\Human Recordings\Exports\nesting.mat');
nestdata = eval('nesting');

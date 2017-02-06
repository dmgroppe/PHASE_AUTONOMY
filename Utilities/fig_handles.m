function [handles] = fig_handles(handles, h, figname)
nh = numel(handles);

handles(nh+1).h = h;
handles(nh+1).name = figname;

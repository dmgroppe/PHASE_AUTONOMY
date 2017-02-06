function [handles] = add_fig_h(handles, h, name)

% Function to collect figure handles for later printing etc.

nhandles = numel(handles);
handles(nhandles+1).h = h;
handles(nhandles+1).name = name;
handles(nhandles+1).rend_mode = '-painters';
handles(end).saveeps = true;
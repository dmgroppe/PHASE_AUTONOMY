function [T,x, from_mat] = get_sl_data(Dir, fname, ch, new_sr, times, load_mat)

if nargin < 6; load_mat = 1; end;

% Gets data from a file

[S, from_mat] = abf_load(Dir, fname, new_sr, times(1), times(2), load_mat);
x = S.data(ch,:);
T = (0:(length(x)-1))/new_sr;

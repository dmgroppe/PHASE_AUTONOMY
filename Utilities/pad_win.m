function [new_array] = pad_win(x, win)
x = x(:);
new_array = padarray(x,[fix(win/2)+1 0],'replicate');
    
function [x,y] = get_8x8grid_xy(ch)

y = ceil(ch/8);
x = rem(ch,8);

if x == 0
    x = 8;
end
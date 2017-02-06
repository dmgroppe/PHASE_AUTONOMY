function [x] = average(x,win)
c   = cumsum(x)./win;
x   = [c(win); c((win+1):end)-c(1:(end-win))];
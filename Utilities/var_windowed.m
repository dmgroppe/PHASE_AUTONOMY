function [v] = var_windowed(x,win)

xpad = padarray(x(:),[fix(win/2)+1 0],'replicate');

x2 = diff(xpad.^2, win);

v = (win*x2-diff(xpad,win).^2)/(win*(win-1));
v = v(1:length(x));


function [d] = diff(x,win)
c = cumsum(x);
d   = [c(win); c((win+1):end)-c(1:(end-win))];
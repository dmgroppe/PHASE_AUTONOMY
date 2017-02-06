function [p] = pearson_corr(x,y, win)


xpad = padarray(x(:),[fix(win/2)+1 0],'replicate');
ypad = padarray(y(:),[fix(win/2)+1 0],'replicate');

numerator = win*diff(xpad.*ypad, win)-diff(xpad, win).*diff(ypad, win);

x2 = diff(xpad.^2, win);
y2 = diff(ypad.^2, win);

sx = win*x2-diff(xpad,win).^2;
sy = win*y2-diff(ypad,win).^2;

p = numerator./(sqrt(sx).*sqrt(sy));
p = p(1:length(x));



function [diff] = diff(x,win)
c = cumsum(x);
diff   = [c(win); c((win+1):end)-c(1:(end-win))];

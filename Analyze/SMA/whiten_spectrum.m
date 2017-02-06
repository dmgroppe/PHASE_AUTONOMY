function [wspec] = whiten_spectrum(w, ps)

if ~isrow(fi(w))
    w = w';
end

if ~isrow(fi(ps))
    ps = ps';
end

logy = log10(ps);
logx = log10(w);

X = [ones(size(logx))', logx'];
[b,~,~,~,~] = regress(logy',X);
yfit = b(1) + b(2)*logx;

wspec = logy - yfit;
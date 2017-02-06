function [] = plot_simple(S, lf, hf, forder, trange)

T = (0:(length(S.data)-1))/2500;

tind = (T>=trange(1) & T<=trange(2));

%d =window_FIR(lf,hf,2500,forder);
d = hp_filter(lf, S.srate, forder);
data = S.data;
for i=1:2
    s(i,:) = filtfilt(d.Numerator,1,data(i,:));
end

plot(T(tind), s(1,tind), T(tind), s(2,tind)- 0.25);
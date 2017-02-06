function [] = tf_mi(x, f1,f2,srate, w)

N = length(x);
x1 = ts_filter(x, f1(1), f1(2), srate);

x2 = ts_filter(x, f2(1), f2(2), srate);
ax2 = abs(hilbert(x2));

[p,loc] = findpeaks(-x1);

count = 0;

for i=1:length(loc)
    count = count+1;
    sstart = loc(i)-w/2+1;
    send = loc(i)+w/2;
    if (sstart > 0 & send <=N)
        x1_seg(:,count) = x1(sstart:send);
        ax2_seg(:,count) = ax2(sstart:send);
    end
end

figure(1);
tseg = (1:w)/srate*1000;
subplot(2,1,1);
plot(tseg,mean(x1_seg,2));

subplot(2,1,2);
plot(tseg,mean(ax2_seg,2));


function [] = plot_tfa(tfa,time, freq,ttext)
surf(time,freq, tfa);
view(0,90);
shading interp;
xlabel('Time (s)');
ylabel('Power');
title(ttext);
caxis([1 2]);
colorbar;
axis square;
axis tight;

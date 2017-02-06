function [] = plot_cgt(y,dt,freqs,srate)
gt = cgt(y, dt, freqs, srate);

T=(0:(length(y)-1))/1000;
surf(T,freqs,abs(gt));
view(0,90);
shading interp;
xlabel('Time (s)');
ylabel('Freq (Hz)');
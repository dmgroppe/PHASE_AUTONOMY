function [] = powerspec_plot(w, ps, ap)

% Function to plot power spectrum

loglog(w,ps);

if ~isempty(ap.ps.yaxis)
    axis([w(1) w(end) ap.ps.yaxis]);
end
set(gca,'TickDir', 'out');
xlabel('Freqency (Hz)');
ylabel('Power');
axis square;
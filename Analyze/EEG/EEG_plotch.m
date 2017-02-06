function [] = EEG_plotch(EEG, channel, figure_no, skip_points)

if nargin < 4; skip_points = 1 ; end

[nchan npoints] = size(EEG.data);
if channel > nchan || nchan < 1
    display('Channel number is out of bounds.')
    return;
end

figure(figure_no);
clf('reset');

plotd = EEG.data(channel,1:skip_points:end);
T = (0:(length(plotd)-1))/EEG.srate*skip_points;
plot(T,plotd);
xlabel('Time (s)');
ylabel('uV');
title(sprintf('Channle #%d', channel));

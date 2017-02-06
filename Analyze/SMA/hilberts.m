function [h] = hilberts(data, srate, aparams)

d = window_FIR(aparams.sync.lowcut, aparams.sync.highcut, srate);
Num = d.Numerator;

[nchan, npoints] = size(data);
h = zeros(nchan, npoints);

 parfor i=1:nchan
     h(i,:) = hilbert(filtfilt(Num, 1, data(i,:)));
 end
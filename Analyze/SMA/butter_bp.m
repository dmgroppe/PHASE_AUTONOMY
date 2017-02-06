function [x] = butter_bp(order, x, srate, lowcut, highcut)

[b,a] = butter(order,lowcut/srate, 'high');
x = filtfilt(b,a,x);

[b,a] = butter(order,highcut/srate, 'low');
x = filtfilt(b,a,x);


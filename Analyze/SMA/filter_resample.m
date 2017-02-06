function [y] = filter_resample(x, oldsrate, newsrate, lowcut, highcut)

% It is important that the newsrate is an integer divider of the oldsrate.
% If not the round off error can lead to significant offsets in large data
% files.

d = window_FIR(lowcut, highcut, oldsrate);

%xfilt = eegfilt(x,oldsrate, lowcut,highcut);
xfilt = filtfilt(d.Numerator, 1, x);
delta = ceil(oldsrate/newsrate);
y = xfilt(1:delta:end);
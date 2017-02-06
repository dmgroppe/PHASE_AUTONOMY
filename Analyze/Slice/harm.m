function [notched] = harm(x,notches,srate, bwidth, maxharm, forder)

% Function to notch filter data across a specified number of harmonics of
% each pronciple frequency

% Notch filters the data over a specified number of harmonics.
% This function can not be parallelized, as each iteration requires th
% eprevious value of the notch filtered data

if nargin <6; forder = 1000; end;

notched = x;

for i=1:length(notches)
    
    nfreq = notches(i);

    harms = nfreq:nfreq:srate/2;

    % Make sure you dont exceed the freq of the data
    nharm = min([maxharm length(harms)]);
    harms = harms(1:nharm);

    for j=1:length(harms)
        b = fir1(forder,[harms(j)-bwidth harms(j)+bwidth]/srate/2, 'stop');
        notched = filtfilt(b, 1, notched);
    end
end
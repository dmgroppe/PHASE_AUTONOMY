function [notched] = harm1(x,notches,srate, bwidth, maxharm, forder)

% Function to notch filter data across a specified number of harmonics of
% each pronciple frequency

% Notch filters the data over a specified number of harmonics.
% This function can not be parallelized, as each iteration requires th
% eprevious value of the notch filtered data

if nargin < 6; forder = 1000; end;

count = 0;

for i=1:length(notches)
    
    nfreq = notches(i);

    harms = nfreq:nfreq:srate/2;

    % Make sure you dont exceed the freq of the data
    nharm = min([maxharm length(harms)]);
    harms = harms(1:nharm);

    for j=1:length(harms)
        count = count + 1;
        f = fir1(forder,[harms(j)-bwidth harms(j)+bwidth]/srate/2, 'stop');
        %f = bstop(harms(j)-bwidth, harms(j)+bwidth, srate, forder);
        if count == 1
            d = f;
        else
            d = d + f;
        end
    end
end

notched = filtfilt(d/count, 1, x);
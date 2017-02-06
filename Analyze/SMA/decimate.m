function [newch] = decimate(ch, newsr, lowcut, highcut)

filtered = eegfilt(ch.data, ch.srate, lowcut, highcut);
skip = int16(ch.srate/newsr);
newch.srate = ch.srate/skip;
newch.data = filtered(1:skip:end);
newch.number = ch.number;
function [ch] = get_channel(EEG, ch_number)
ch.data = EEG.data(ch_number,:);
ch.srate = EEG.srate;
ch.number = ch_number;
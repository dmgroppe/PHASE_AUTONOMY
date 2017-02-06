function [ch_sub] = get_ch_subregion(EEG, ch, tstart, tend)

%tstart, and tend are in milliseconds

sstart = floor(tstart*EEG.srate/1000);
if (sstart <= 0)
    sstart = 1;
end

send =  floor(tend*EEG.srate/1000);
if ( send > length(EEG.data))
    send = length(EEG.data);
end
ch_sub  = EEG.data(ch,sstart:send);
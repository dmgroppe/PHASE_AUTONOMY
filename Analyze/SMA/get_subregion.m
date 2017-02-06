function [sub] = get_subregion(EEG, tstart, tend)

%tstart, and tend are in milliseconds

sstart = floor(tstart*EEG.srate/1000);
if (sstart <= 0)
    sstart = 1;
end

send =  floor(tend*EEG.srate/1000)-1;
if ( send > length(EEG.data))
    send = length(EEG.data);
end
sub  = EEG.data(:,sstart:send);

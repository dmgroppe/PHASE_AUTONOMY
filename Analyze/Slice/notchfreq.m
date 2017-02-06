function [freqarray m] = notchfreq(ap)

freqarray = [];
m = [];
noisef = ap.notches;
nyq = ap.srate/2;
ftype = ap.filter.ftype;
if strcmp(ftype,'firnotch') == 1
    %build up array of frequencies 'freqarray'
    for i = 1:length(noisef)
        for j = 1:ap.nharm
            if j*noisef(i) < nyq
                freq = noisef(i)*j;
                freqarray = [freqarray (freq-0.5)/nyq (freq+0.5)/nyq];
            end
        end
    end
    freqarray = unique(freqarray); %make sure there are no duplicate entries
    freqarray = sort(freqarray); %make sure frequencies are in ascending order
elseif strcmp(ftype,'iirnotch') == 1
    %Build up frequency array 'freqarray' and array of amplitudes 'm'
    for i = 1:length(noisef) 
        for j = 1:ap.nharm
            if j*noisef(i) < nyq
                freq = noisef(i)*j;
                freqarray = [freqarray (freq-0.5)/nyq freq/nyq (freq+0.5)/nyq];
                m = [m 1 0 1];
            end
        end
    end
    [freqarray ii] = unique(freqarray); %make sure there are no duplicate entries
    m = m(ii);
    [freqarray ii] = sort(freqarray); %make sure frequencies are in ascending order
    m = m(ii);
    if freqarray(1) ~= 0 %Make sure to include relative frequency '0'
        freqarray = [0 freqarray]; m = [1 m];
    end
    if freqarray(length(freqarray)) ~= 1 %Make sure to include relative frequency '1'
        freqarray = [freqarray 1]; m = [m 1];
    end
end

end
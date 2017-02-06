function [notched]= filter_notch(EEG, chtoexcl, fstop, bwidth)

nchan = size(EEG.data, 1);
Hd = bstop(fstop-bwidth, fstop+bwidth, EEG.srate);

notched = EEG;
for i=1:nchan
    if isempty(find(i==chtoexcl, 1))
        notched.data(i,:) = filtfilt(Hd.Numerator, 1, EEG.data(i,:));
    end
end


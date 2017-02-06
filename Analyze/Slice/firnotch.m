function data = firnotch(data,ap)
%INPUTS:
%data       - input data
%noisef     - array of frequencies to notch out
%srate      - sampling rate
%OUTPUTS:
%data       - filtered data

freqarray = notchfreq(ap);
fc = fir1(ap.firnotch.order,freqarray,'stop'); %notch filter design
if size(data,2) == 1; data = data'; end %Make data row vector if necessary

for i = 1:size(data,1)
    data(i,:) = filtfilt(fc,1,data(i,:)); %implement filter for each data instance
end

end
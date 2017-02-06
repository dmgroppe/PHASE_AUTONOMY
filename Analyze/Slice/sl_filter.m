function [dfilt] = sl_filter(S, F)

nchan = size(S.data,1);

for i=1:nchan
    dfilt(i,:) = filtfilt(F.Numerator, 1, S.data(i,:));
end
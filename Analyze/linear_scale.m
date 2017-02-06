function [scales] = linear_scale(freq, sr)

%function [scales] = linear_scale(freq, sr)
% freq - frequencies 
% sr - sampling rate 
beta =  -1;
scales =fliplr(sr*freq.^beta);
scales = sort(scales, 'descend');

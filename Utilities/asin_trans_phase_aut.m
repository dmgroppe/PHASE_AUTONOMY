function p=asin_trans(data)
%function p=asin_trans(data)
%
% data = vector of values between 0 and 1
%
%Outputs the arcsin of the sqrt of x in degrees
%  p=asin(sqrt(data))*180/pi;
%
% Output values will range from 0 to 90 degrees
% 
% Author: David Groppe

if max(data)>1
    error('data contains values greater than 1');
elseif min(data)<0
    error('data contains values less than 0');
end

%This is the vanilla arcsin transformation
p=asin(sqrt(data))*180/pi;

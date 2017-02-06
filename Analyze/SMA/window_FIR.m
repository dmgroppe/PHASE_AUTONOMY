function Hd = window_FIR(Fc1, Fc2, Fs, forder)
%TESTF Returns a discrete-time filter object.

if nargin < 4; forder = 10000; end;

%
% M-File generated by MATLAB(R) 7.10 and the Signal Processing Toolbox 6.13.
%
% Generated on: 14-Aug-2011 19:40:55
%

% FIR Window Bandpass filter designed using the FIR1 function.

% All frequency values are in Hz.
%Fs = 1000;  % Sampling Frequency

N             = forder;     % Order
%Fc1           = 60;       % First Cutoff Frequency
%Fc2           = 62;       % Second Cutoff Frequency
flag          = 'scale';  % Sampling Flag
SidelobeAtten = 100;      % Window Parameter
% Create the window vector for the design algorithm.
win = chebwin(N+1, SidelobeAtten);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, [Fc1 Fc2]/(Fs/2), 'bandpass', win, flag);
Hd = dfilt.dffir(b);

% [EOF]

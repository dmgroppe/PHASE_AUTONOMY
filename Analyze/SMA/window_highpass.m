function Hd = window_highpass(Fc, Fs, forder)
%WINDOW_HIGHPASS Returns a discrete-time filter object.

%
% M-File generated by MATLAB(R) 7.10 and the Signal Processing Toolbox 6.13.
%
% Generated on: 28-Aug-2011 17:16:30
%

% FIR Window Highpass filter designed using the FIR1 function.

% All frequency values are in Hz.
%Fs = 1000;  % Sampling Frequency

if nargin < 3; forder = 10000; end;

N             = forder;     % Order
%Fc            = 2;        % Cutoff Frequency
flag          = 'scale';  % Sampling Flag
SidelobeAtten = 100;      % Window Parameter

% Create the window vector for the design algorithm.
win = chebwin(N+1, SidelobeAtten);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Fc/(Fs/2), 'high', win, flag);
Hd = dfilt.dffir(b);

% [EOF]

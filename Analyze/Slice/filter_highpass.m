function Hd = filter_highpass(Fc, Fs, N)
%FILTER_HIGHPASS Returns a discrete-time filter object.

%
% MATLAB Code
% Generated by MATLAB(R) 7.12 and the Signal Processing Toolbox 6.15.
%
% Generated on: 26-Aug-2012 10:15:46
%

% FIR Window Highpass filter designed using the FIR1 function.

% All frequency values are in Hz.
%Fs = 2500;  % Sampling Frequency

%N    = 1000;     % Order
%Fc   = 1;        % Cutoff Frequency
flag = 'scale';  % Sampling Flag

% Create the window vector for the design algorithm.
win = hamming(N+1);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Fc/(Fs/2), 'high', win, flag);
Hd = dfilt.dffir(b);

% [EOF]

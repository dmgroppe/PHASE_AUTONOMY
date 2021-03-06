function b = bstop(Fc1, Fc2, Fs, forder)
%BSTOP Returns a discrete-time filter object.

%
% M-File generated by MATLAB(R) 7.10 and the Signal Processing Toolbox 6.13.
%
% Generated on: 27-Jul-2011 01:13:35
%

% FIR constrained least-squares Bandstop filter designed using the FIRCLS
% function.

% All frequency values are in Hz.
%Fs = 500;  % Sampling Frequency

if nargin < 4; forder = 1000; end;

N       = forder;  % Order
%Fc1     = 178;   % First Cutoff Frequency
%Fc2     = 182;   % Second Cutoff Frequency
Dpass1U = 0.1;   % Upper Passband Ripple
Dpass1L = 0.1;   % Lower Passband Ripple
DstopU  = 0.1;   % Upper Stopband Attenuation
DstopL  = 0.1;   % Lower Stopband Attenuation
Dpass2U = 0.1;   % Upper Passband Ripple
Dpass2L = 0.1;   % Lower Passband Ripple

% Calculate the coefficients using the FIRCLS function.
b  = fircls(N, [0 Fc1 Fc2 Fs/2]/(Fs/2), [1 0 1], [1+Dpass1U DstopU ...
            1+Dpass2U], [1-Dpass1L -DstopL 1-Dpass2L]);
%Hd = dfilt.dffir(b);

% [EOF]

function Hd = hp_filter(Fc, Fs, Forder)

if nargin < 3; Forder = 10000; end;

%LP_FILTER Returns a discrete-time filter object.

%
% MATLAB Code
% Generated by MATLAB(R) 7.12 and the Signal Processing Toolbox 6.15.
%
% Generated on: 29-May-2013 21:14:45
%

% FIR Window Highpass filter designed using the FIR1 function.

% All frequency values are in Hz.
%Fs = 2500;  % Sampling Frequency

N    = Forder;    % Order
%Fc   = 2;        % Cutoff Frequency
flag = 'scale';  % Sampling Flag

% Create the window vector for the design algorithm.
win = rectwin(N+1);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Fc/(Fs/2), 'high', win, flag);
Hd = dfilt.dffir(b);

% [EOF]

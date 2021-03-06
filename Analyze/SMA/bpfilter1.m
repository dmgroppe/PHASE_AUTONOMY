function Hd = bpfilter1(Fpass1, Fpass2, Fs)
%BPFILTER1 Returns a discrete-time filter object.

%
% M-File generated by MATLAB(R) 7.10 and the Signal Processing Toolbox 6.13.
%
% Generated on: 27-Jul-2011 03:03:08
%

% Equiripple Bandpass filter designed using the FIRPM function.

% All frequency values are in Hz.
%Fs = 500;  % Sampling Frequency

%N      = 10;  % Order
Fstop1 = Fpass1-2;    % First Stopband Frequency
%Fpass1 = 58;    % First Passband Frequency
%Fpass2 = 60;    % Second Passband Frequency
Fstop2 = Fpass2+2;    % Second Stopband Frequency
Dstop1 = 0.001;           % First Stopband Attenuation
Dpass  = 0.057501127785;  % Passband Ripple
Dstop2 = 0.0001;          % Second Stopband Attenuation
dens   = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2]/(Fs/2), [0 1 ...
                          0], [Dstop1 Dpass Dstop2]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(b);

% [EOF]

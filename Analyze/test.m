% Author: Fei Chu
% Johns Hopkins University, 2008

clear;
clc;

name=input('Please enter wav file name(e.g. sig):','s');
if isempty(name)
    name='sig';
end
[sig,fs]=wavread(name);
display([name,'.wav file loaded. Length:',num2str(length(sig)/fs),' s']);

t0  = str2num(input('Please input the stim start time(e.g. 0):','s'));
if isempty(t0)
    t0=0;
end

T  = str2num(input('Please input the stim end time(e.g. 0.2):','s'));
if isempty(T)
    T=0.2;
end

sig=sig(t0*fs+1:T*fs);
t = ((0:length(sig)-1)/fs)';

pause=input('Press any key to play the stimulus signal...');
sound(sig,fs);

bw  = str2num(input('Please input the complex morlet wavelet bandwidth parameter(e.g. 10):','s'));
if isempty(bw)
    bw=10;
end

figure;
subplot(2,1,1);
plot(t,sig);
title('Sig');
xlim([0 (length(sig)-1)/fs]);

subplot(2,1,2);
scalogram(sig,fs,80,'log',jet,bw);
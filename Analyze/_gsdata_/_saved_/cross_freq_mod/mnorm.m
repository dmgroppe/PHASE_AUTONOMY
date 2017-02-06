function [] = mnorm(x, srate, lowfs, highfs)
numpoints=length(x); %% number of sample points in raw signal
numsurrogate=200; %% number of surrogate values to compare to actual value
minskip=srate; %% time lag must be at least this big
maxskip=numpoints-srate; %% time lag must be smaller than this
skip=ceil(numpoints.*rand(numsurrogate*2,1));
skip(find(skip>maxskip))=[];
skip(find(skip<minskip))=[];
skip=skip(1:numsurrogate,1);
surrogate_m=zeros(numsurrogate,1);
%% HG analytic amplitude time series, uses eegfilt.m from EEGLAB toolbox
%% (http://www.sccn.ucsd.edu/eeglab/)
HG = eegfilt(x,srate,highfs(1),highfs(2));
amplitude=abs(hilbert(HG));
%% theta analytic phase time series, uses EEGLAB toolbox
Theta = eegfilt(x,srate,lowfs(1),lowfs(2));
phase=angle(hilbert(Theta));

%% complex-valued composite signal
z=amplitude.*exp(1i*phase);
X = 1:numpoints;
ax(1) = subplot(3,1,1);
plot(X, x);
title('Original signal');
ax(2) = subplot(3,1,2);
plot(X,abs(z));
title('Amplitude of composite signal');
ax(3) = subplot(3,1,3);
plot(X,phase);
title('LF phase');
linkaxes(ax, 'x');

%% mean of z over time, prenormalized value
m_raw=mean(z);
%% compute surrogate values
for s=1:numsurrogate
    surrogate_amplitude=[amplitude(skip(s):end) amplitude(1:skip(s)-1)];
    surrogate_m(s)=abs(mean(surrogate_amplitude.*exp(1i*phase)));
    %disp(numsurrogate-s);
end
%hist(surrogate_m);
%% fit gaussian to surrogate data, uses normfit.m from MATLAB Statistics toolbox
[surrogate_mean,surrogate_std]=normfit(surrogate_m);
%% normalize length using surrogate data (z-score)
m_norm_length=(abs(m_raw)-surrogate_mean)/surrogate_std
m_norm_phase=angle(m_raw)
%m_norm=m_norm_length*exp(i*m_norm_phase);
% clear all
% close all
% clc
% load('NA_d1_sz2.mat');
chan1=11;
chan2=18;
hx=matrix_bi(:,chan1);
hy=matrix_bi(:,chan2);
freq=25;
Fc=freq/5;
Fb=0.5;
scale=Fc*Sf/freq;
wname=['cmor' num2str(Fb) '-' num2str(Fc)];
output=cwt_fluctuation(hx,hy,scale,Sf,wname);
plot(output);
title(['Fluctuations, @' num2str(freq) 'Hz ,C' num2str(chan1) '-C' num2str(chan2)]);
  
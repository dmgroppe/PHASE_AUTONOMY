function outMtrx=smoothMtrx(inMtrx,srate,timeSpan)
%function outMtrx=smoothMtrx(inMtrx,srate,timeSpan)
%
% This function smooths a time series using a hamming window
%
% Inputs:
%  inMtrx - time x variable matrix
%  srate  - sampling rate
%
% Optional Input:
%  timeSpan - length of hamming window (in seconds). {default: 0.5}


if nargin<3.
    timeSpan=.5; 
end

[nTpt, nVar]=size(inMtrx);

%% compute hamming window for smoothing data later
nHamTpt=round(timeSpan*srate);
if iseven(nHamTpt)
    nHamTpt=nHamTpt+1; % make odd;
end
fprintf('Length of hamming window is %d time points.\n',nHamTpt);
hamWind=hamming(nHamTpt);
hamWind=hamWind/sum(hamWind);
nSmoothTpt=nTpt-nHamTpt+1;
outMtrx=single(zeros(nSmoothTpt,nVar));

for a=1:nVar,
   outMtrx(:,a)=conv(inMtrx(:,a),hamWind,'valid'); 
end

% temp=squeeze(mean(thisChanSgram(1:onsetWind,bbandIds),2));
% %temp=squeeze(mean(allSgram(1:onsetWind,bbandIds,cLoop),2));
% bbPwr(:,cLoop)=conv(temp,hamWind,'valid');
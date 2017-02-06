% Author: Fei Chu
% Johns Hopkins University, 2008

function varargout=scalogram(sig,fs,varargin)
% [t,a,f,S,dBS] = scalogram(signal,sample_rate, [[dynrange],'yscale',colormap, bandwidth parameter])
% scalogram(signal, sample_rate, [[dynrange],'yscale',colormap, bandwidth parameter])
% Plots scalogram of speech.
% Sample rate is in Hz.
% Plots scalogram, and also returns time series, scale set, frequency set,
% wavelet power coefficient matrix, and its form in dB scale.
%varargin{1}  yscale 'linear' 'log'
%varargin{2}  dynamic range e.g.60dB
%varargin{3}  colormap e.g. 1-gray jet
%varargin{4}  bandwidth parameter  e.g. 10


%default
range=60;
yscale='log';
colormp=jet;
bw=10;

if nargin>=3
    range=varargin{1};
end

if nargin>=4
    yscale=varargin{2};
end

if nargin>=5
    colormp=varargin{3};
end

if nargin>=6
    bw=varargin{4};
end

wvname=['cmor',num2str(bw),'-1'];


t = ((0:length(sig)-1)/fs)';

if strcmp(yscale,'linear')
 alpha =  fs;
 beta =  -1;
 freq=[300:100:10500];
 a =fliplr(alpha*freq.^beta);
else
 a=[1:0.5:45.5 46:2:128];
end

coefs = cwt(sig,a,wvname);
S=coefs.*coefs;
maxS = max(max(abs(S))); minS = 10^-8*maxS;
dBS = 20*log10(max(abs(S), minS));
maxdBS = max(max(dBS));
mindBS = min(min(dBS));
dBS = min(maxdBS, max(maxdBS-range, dBS));

delta = 1/fs; wname = wvname; 
f = scal2frq(a,wname,delta);

display(['scale  frequency']);
display([a' f']);

mesh(t,f,dBS);
set(gca,'YScale',yscale);
colormap(colormp);
xlim([0 (length(sig)-1)/fs]);
ylim([min(f) 10000]);
ylabel('Frequency (Hz)');
xlabel('Time (s)');
title(['Morlet Wavelet Scalogram (',num2str(range),'dB, ',yscale,' scale, bw parameter=',num2str(bw),')']);
view(2);
if strcmp(yscale,'log')
    set(gca,'YTick',[(1:9)*1e2 (1:9)*1e3 10000])
    set(gca,'YTickLabel',[(1:9)*1e2 (1:9)*1e3 10000])
end

% Return outputs, if requested
if nargout>0; varargout(1) = {t};
	if nargout>1; varargout(2) = {a};
		if nargout>2; varargout(3) = {f};
			if nargout>3; varargout(4) = {S};
                if nargout>4; varargout(5) = {dBS};
                end
            end
		end
	end
end
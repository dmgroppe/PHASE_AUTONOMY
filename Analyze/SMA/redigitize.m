function [EEGdig] = redigitize(EEG,ch,bits)

%ap = sync_params();

range = 995*2;  % Range is 2000 uV as per the Neuroscan hardware

%[subr] = data_retrieve(EEG, cond, ap.length, ptname);
x = EEG.data(ch,:);
%x = x-mean(x);

adc = x/range*2^bits;

xdig = fix(adc)*range/2^bits;
EEGdig = EEG;
EEGdig.data = xdig;

% 
% if doplot
%     
%     T = ((1:length(x))-1) * EEG.srate; % Time in seconds
% 
%     figure(1);
%     plot(T,x,T,xdig);
% 
%     figure(2);
% 
%     [xps, w, ~] = powerspec(x,2000,EEG.srate);
%     xdigps = powerspec(xdig,2000,EEG.srate);
% 
%     loglog(w,xps,w,xdigps);
%     xlabel('Frequency (Hz)');
%     ylabel('Power');
% end

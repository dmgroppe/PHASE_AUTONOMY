function [] = ps_EEG_ch(EEG, times, channel, window, nslep)

if nargin < 4; window = EEG.srate; end;
if nargin < 5; nslep = 3; end;

samp = times*60*EEG.srate;

[ps, w, ~] = powerspec(EEG.data(channel,samp(1):samp(2)),window, EEG.srate, nslep);

fname = sprintf('ps_EEG Ch# %d', channel);
set(gcf, 'Name', fname);

fmax = EEG.srate/5;
findex = find (w >= fmax & w <= fmax);

loglog(w(1:findex), ps(1:findex));
xlabel('Frequency (Hz)');
ylabel('Power');
title(fname);

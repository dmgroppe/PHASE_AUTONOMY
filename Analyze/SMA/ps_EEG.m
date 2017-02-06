function [] = ps_EEG(EEG, times, window, nslep)

if nargin < 3; window = EEG.srate; end;
if nargin < 4; nslep = 3; end;

samp = times*60*EEG.srate;
nchan = size(EEG.data,1);

data = EEG.data(:,samp(1):samp(2));
srate= EEG.srate;

parfor i = 1:nchan
    [ps(:,i), w(:,i), ~] = powerspec(data(i,:),window, srate, nslep);
end

w = w(:,1);
h = figure(1);
fname = sprintf('ps_EEG');
set(h, 'Name', fname);

fmax = EEG.srate/5;
findex = find (w >= fmax & w <= fmax);

maxp = max(max(ps));
minp = min(min(ps));

for i=1:nchan
    ax(i) = subplot(8,8,i);
    loglog(w(1:findex), ps(1:findex, i));
    %axis([w(1) w(end) minp maxp]);
    set(gca, 'FontName', 'Times', 'FontSize', 5);
    title(sprintf('CH%d', i));
    %xlabel('Frequency (Hz)');
    %ylabel('Power');
    %title(fname);
end

linkaxes(ax, 'xy');

function [err] = zap_load(Dir, fn, frange, trange)

if nargin < 3; frange = [1 20]; end;

err = 0;

path = [Dir fn , '.abf'];
if ~exist(path, 'file')
    display('File does not exist');
    return;
end

set(gcf, 'Name', fn);

[d,si,h]=abfload(path);

if size(d,3) > 1
    % This means there were multiple episodes so not a ZAP function
    display(sprintf('%s - is like not a ZAP  protocol', upper(fn)));
    err = 1;
    return;
end
sr = 1/(si*1e-6);
T = (0:length(d)-1)/sr*1e3;

% Discard the crap at either end of the data.
tp = find(T > trange(1) & T < trange(2));

d = squeeze(d(tp,1,:))*1e-3; % Convert to volts
npoints = length(d);
subplot(2,3,[1 3]);
plot(T(tp)*1e-3, d-mean(d));

[wave, ~] = zap(1, frange, trange(2)/1e3, sr);
bp = window_FIR(frange(1),frange(2)-2,sr);
xfilt = filtfilt(bp.Numerator,1, d);
wfilt = filtfilt(bp.Numerator,1, wave);
[ps_data,~,~] = powerspec(xfilt',npoints,sr);
[ps_zap,w, ~] =  powerspec(wfilt(1:npoints),npoints,sr);
wpoints = find(w>2 & w < 16);
Z = ps_data./ps_zap;

subplot(2,3,4);
loglog(w(wpoints), ps_zap(wpoints));
title('ZAP');

subplot(2,3,5);
loglog(w(wpoints), ps_data(wpoints));
title('DATA');

subplot(2,3,6);
bline = Z(wpoints);
Z_norm = Z(wpoints)/mean(bline(1:10));


loglog(w(wpoints),Z(wpoints));
title('Z');
axis([min(w(wpoints)), max(w(wpoints)), 0, 1.2]);
    


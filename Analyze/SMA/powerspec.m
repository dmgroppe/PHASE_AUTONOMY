function [ps, w, pxx] = powerspec(x,window, srate, usemt, nslep)

% USAGE: [ps, w, pxx] = powerspec(x,window, srate, nslep)

% INPUT:
% x:        the vector of data
% window:   size of the window to compute PS over
% srate:    Sampling rate in Hz
% nslep:    Number of tapers

% OUTPUT:
% ps:       The average power spectrum
% w:        frequencies
% pxx:      The individual power spectra

% Taufik A Valiante 2011

if nargin < 5; nslep = 2.5; end;
if nargin < 4; usemt = 1; end;

npoints = length(x);

sstart = 1;
send = window;
pcount = 0;
ps = [];

x = x(:);
while (send <=npoints)
    
    ts = x(sstart:send);
    
    % Each segment is hanning windowed to remove edge effects
    ts = hann(length(ts)).*(ts-mean(ts));
    
    if usemt
        [Pxx, w] = pmtm(ts,nslep,window,srate);
    else
        [Pxx, w] = pspec_fft(ts, srate);
    end
    
    if (pcount == 0)
        ps = Pxx;
    else
        ps = ps + Pxx;
    end
    pcount = pcount + 1;
    pxx(pcount,:) = Pxx;
    sstart = send;
    send = sstart + window;
end

ps = ps/pcount;
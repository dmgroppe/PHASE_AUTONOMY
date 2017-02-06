function [ps, w] = psd(x,window, srate)

npoints = length(x);

sstart = 1;
send = window;
pcount = 0;
ps = [];
while (send <=npoints)
    [Pxx, w] = pmtm(x(sstart:send),[],window,srate);
    if (pcount == 0)
        ps = Pxx;
    else
        ps = ps + Pxx;
    end
    pcount = pcount + 1;
    sstart = send;
    send = sstart + window;
end

ps = ps/pcount;

%semilogy(w,ps);
loglog(w,ps);
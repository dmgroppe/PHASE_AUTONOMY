function [] = sync_tevolution(EEG, cond, chs, frange, w_length, atype, surr)

if nargin < 7; surr = 0; end;

tstep = 1;


[tstart tend] = get_trange(cond, 60);
subr = get_subregion(EEG, tstart, tend);
subr = subr(chs,:);
npoints = length(subr);

aparams.sync.lowcut = frange(1);
aparams.sync.highcut = frange(2);

if surr
    subr(1,:) = rand_rotate(subr(1,:));
end

h = hilberts(subr, EEG.srate, aparams);
fh = sync_fh(atype);

sstart = 1;
send = w_length;
count = 0;

while send <= npoints-w_length; 
    count = count + 1;
    syncs(count) = abs(fh(h(1,sstart:send), h(2, sstart:send)));
    sstart = sstart + tstep;
    send = send + tstep;
end

figure(1);
plot(syncs);

figure(2);

[ps, w, ~] = powerspec(syncs,2*w_length, EEG.srate);
loglog(w, ps);

figure(3)
wspec = whiten_spectrum(w(4:end)', ps(4:end)');
semilogx(w(4:end), wspec);



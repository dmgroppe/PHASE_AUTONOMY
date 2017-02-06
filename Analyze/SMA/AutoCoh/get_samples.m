function [sstart send] = get_samples(EEG,cond,ap,ptname)
[tstart tend] = get_trange(cond, ap.length, ptname);
sstart = floor(tstart*EEG.srate/1000);
send =  floor(tend*EEG.srate/1000)-1;
function [ts, surr] = sim_autocoh(R, stim, rest, ptname, nsurr, type)

nfreq = numel(R.bursts);
% Scramble the pahses for the rest state
[rest_surr,~]=IAAFT(rest,1);

for i=1:nfreq
    nbursts = length(R.bursts{i})
end




% [tstart tend] = get_trange(acond, ap.length, ptname);
% subr = get_subregion(EEG, tstart, tend);
% stim = subr(ch,:);
% 
% [tstart tend] = get_trange('rest_eo', ap.length, ptname);
% subr = get_subregion(EEG, tstart, tend);
% rest = subr(ch,:);
% 
% h = figure(1);
% subplot(2,1,1);
% plot_spectra(stim, rest, EEG.srate, {'Stim','Rest'});
% 
% tic
% [surr_stim,~]=IAAFT(stim,1);
% [surr_rest,~]=IAAFT(rest,1);
% toc
% 
% subplot(2,1,2);
% plot_spectra(surr_stim', surr_rest', EEG.srate, {'Surr_Stim','Surr_Rest'});


function [x1spec x2spec] = plot_spectra(x1, x2, srate, ltext)

[x1spec, ~, ~] = powerspec(x1,srate, srate);
[x2spec, w, ~] = powerspec(x2,srate, srate);

loglog(w,x1spec, w, x2spec);
legend(ltext);
xlabel('Freq Hz')
ylabel('Power');

function [ts, surr] = surr_subr(EEG,ch,ptname,cond, nsurr,ap)
[tstart tend] = get_trange(cond, ap.length, ptname);
subr = get_subregion(EEG, tstart, tend);
ts = subr(ch,:);
[surr,~]=IAAFT(ts,nsurr);
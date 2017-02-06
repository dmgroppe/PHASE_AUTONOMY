function [] = sync_ph_env_hist(EEG, ch, lfrange, hfrange, cond, ptname, surr)

if nargin < 7; surr =  0; end;

ap = sync_params();

ts = data_retrieve(EEG, cond, ap.length, ptname);
ts = ts(ch,:);

[ts, low_osc, high_mod, noise] = sim_nesting(get_default_sim_params());

d = window_FIR(lfrange(1), lfrange(2), EEG.srate);
lf_phase = angle(hilbert(filtfilt(d.Numerator, 1, ts)));


d = window_FIR(hfrange(1), hfrange(2), EEG.srate);
hf_env = abs(hilbert(filtfilt(d.Numerator, 1, ts)));

[MI, p] = sync_mi(lf_phase, hf_env, ap.mi.nbins, 1);

display(sprintf('\nMI = %6.2e, p = %6.2e\n', MI, p));
% 
% if surr
%     display('Performing surrogate calculations');
%     for i=1:ap.nsurr
%         rot_hf_env = rand_rotate(hf_env);
%         surr_amps = peh(lf_phase, rot_hf_env, ap.peh.nbins);
%         surr_mi(i) =  KL_distance(surr_amps, uniform)/log(length(centers));
%     end
%     p = (length(find(surr_mi > MI))+1)/(ap.nsurr+1);
%     fprintf('\np = %6.2e\n', p);
% end
%     
% function [mean_amps] = peh(lf_phase, hf_env, nbins)
% 
% [~, ~, amps] = sync_peh(lf_phase, hf_env, nbins);
% 
% for i=1:numel(amps)
%     mean_amps(i) = mean(amps{i});
% end

%beta = nlinfit(centers,mean_amps, @vm_1,[mean(mean_amps),pi,1]);
%pfit = vm_1(beta,centers);






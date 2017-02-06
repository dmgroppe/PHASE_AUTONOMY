function [] = sync_envlfp_corr(EEG, cond, ptname, dlength, channel, lrange, hrange)

nsurr = 200;


[tstart tend] = get_trange(cond, dlength, ptname);
x = get_ch_subregion(EEG, channel, tstart, tend);

t = (0:length(x)-1)/EEG.srate;

lowlfp = filter_t(x, lrange, EEG.srate);
high_env = abs(hilbert(filter_t(x, hrange, EEG.srate)));

norm_lowlfp = lowlfp/std(lowlfp);
norm_high_env = high_env/std(high_env);

norm_lowlfp = norm_lowlfp - mean(norm_lowlfp);
norm_high_env = norm_high_env - mean(norm_high_env);

plot(t, norm_lowlfp, t,norm_high_env);
xlabel('Time (s)');
ylabel('Normalized power');
legend({'Low freq LFP','High freq envelope'});

base_corr = fisherZ(pearson_corr(norm_lowlfp,norm_high_env));


surr_corr = zeros(1,nsurr);
for i=1:nsurr
    shifted = rand_rotate(norm_high_env);
    surr_corr(i) = fisherZ(pearson_corr(norm_lowlfp,shifted));
end

[surrogate_mean,surrogate_std]=normfit(surr_corr);
z = (base_corr-surrogate_mean)/surrogate_std;
p = 2*(1-normcdf(abs(z),0,1));

fprintf('p = %6.4f\n', p);


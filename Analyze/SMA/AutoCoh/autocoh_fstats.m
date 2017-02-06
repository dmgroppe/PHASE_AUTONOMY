function [] = autocoh_fstats(freqs,srate,R, R_burst_surr, R_noise_surr)

%ap = sync_params();

nsurr = numel(R_noise_surr);
c_data = zeros(1,length(R.counts));
c_burst = c_data;
c_avglengths = c_data;
c_counts = c_data;
c_avgamps = c_data;

data_marginal = R.ac_count./R.counts;

%Get the average burst marginal from all the surrogates
bm = zeros(1,length(R_burst_surr{1}.ac_count));
for i=1:nsurr
    bm = bm+R_burst_surr{i}.ac_count./R_burst_surr{i}.counts;
end
burst_marginal = bm/nsurr;

for i=1:nsurr
    surr_marginals(:,i) = (R_noise_surr{i}.ac_count./R_noise_surr{i}.counts);
    c_data = c_data + (surr_marginals(:,i)' > data_marginal);
    c_burst = c_burst + (surr_marginals(:,i)' > burst_marginal);
    
    avglengths(:,i) = R_burst_surr{i}.avglengths;
    c_avglengths = c_avglengths+(avglengths(:,i)' > R.avglengths);
    
    counts(:,i) = R_burst_surr{i}.counts;
    c_counts = c_counts+(counts(:,i)' > R.counts);
    
    avgamps(:,i) = R_burst_surr{i}.avgamps;
    c_avgamps = c_avgamps+(avgamps(:,i)' > R.avgamps);
end

p_data = (c_data + 1)/(nsurr+1);
p_burst = (c_burst + 1)/(nsurr+1);

sig_burst = fdr_vector(p_burst,0.05,false);
sig_data = fdr_vector(p_data,0.05,false);

[~, burst_new_sig] = sig_to_ranges(sig_burst, freqs, 3);
[~, data_new_sig] = sig_to_ranges(sig_data, freqs, 3);

h = figure(1);
clf;
subplot(3,1,1);
plot(freqs,data_marginal, freqs, burst_marginal);
title('Marginal distributions');
% Plot the 95% condfidence interval for the noise surrogate
%sem = sqrt(var(surr_marginals,1,2)'/nsurr)*1.96;
sem = 2*std(surr_marginals,1,2)';
boundedline(freqs, mean(surr_marginals,2)', sem, 'r', 'transparency', 0.1);
legend({'P data', 'P burst', 'Surrogate'});
set(gca, 'TickDir', 'out');

subplot(3,1,2);
plot(freqs, burst_new_sig);
title('Burst significance');
set(gca, 'TickDir', 'out');

subplot(3,1,3);
plot(freqs, data_new_sig);
xlabel('Frequency (Hz)');
ylabel('Significance');
title('Data significance');
set(gca, 'TickDir', 'out');

h = figure(2);
set(h, 'Name', 'Burst statistics for NOISE simulation');
plot_R_means(freqs, srate, R_noise_surr);

h = figure(3);
set(h, 'Name', 'Burst statistics for BURST simulation');
plot_R_means(freqs, srate, R_burst_surr);

h = figure(4);
set(h, 'Name', 'Burst statistics for DATA');
plot_autocoh(sync_params, R, srate, freqs);

% h= figure(5);
% set(h,'Name', 'Data vs. Burst parameters');

%plot_stats(freqs,R.avglengths,avglengths,c_avgamps, 0.05, false);
 

function [] = plot_R_means(freqs, srate, R)

nsurr = numel(R);
hlengths = 0;
avglengths = 0;
counts = 0;
avgamps = 0;
ac_count = 0;
prob_dist = 0;

for i=1:nsurr
    hlengths = hlengths + R{i}.hlengths;
    avglengths = avglengths + R{i}.avglengths;
    counts = counts + R{i}.counts;
    avgamps = avgamps + R{i}.avgamps;
    ac_count = ac_count + R{i}.ac_count;
    prob_dist = prob_dist + R{i}.prob_dist;
end

Ra.hlengths = hlengths/nsurr;
Ra.avglengths = avglengths/nsurr;
Ra.counts = counts/nsurr;
Ra.avgamps = avgamps/nsurr;
Ra.ac_count = ac_count/nsurr;
Ra.prob_dist = prob_dist/nsurr;

plot_autocoh(sync_params(), Ra, srate, freqs);

function [] = plot_stats(freqs,data,surr,counts, alpha, stringent)
surr_mean = mean(surr,2);
sem = std(surr,1,2)*2;

plot(freqs,data);
boundedline(freqs, surr_mean, sem, 'r', 'transparency', 0.1);
legend({'Data', 'Burst Model'});
set(gca, 'TickDir', 'out');






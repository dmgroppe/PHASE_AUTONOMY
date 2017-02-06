function [] = causal_spike_train(do_ccm)

if nargin <1; do_ccm = 0; end;

frange = [15 30];
N = 10000;
totalT = 10; %(in seconds);
srate = N/totalT;

tvar = 1; % IN ms
tshift = 10;
tshift_var = 1;
klength = 100;
ccm_resample = 1;

x = randn(1,N);
T = (0:(length(x)-1))/srate;

d = window_FIR(frange(1), frange(2), srate, 100);
xfilt = filtfilt(d.Numerator, 1, x);

clf;
ax(1) = subplot(2,1,1);
plot(T, xfilt);
[pks, loc] = findpeaks(xfilt);
hold on;
plot(T(loc), xfilt(loc), '.r', 'LineStyle', 'none');
hold off;
avgT = mean(diff(T(loc)));
display(sprintf('Average frequency = %6.2f Hz', 1/avgT));

% create distribution of spikes at preferred phase

pvar = (tvar*1000)/srate;
pshift = (tshift*1000)/srate;
sp_times = fix((randn(1,length(loc))-0.5)*pvar) + pshift...
    + fix((randn(1,length(loc))-0.5)*tshift_var);
sp_times = loc+sp_times;
neg_times = find(sp_times <= 0);
sp_times(neg_times) = [];

loc_times = loc;
loc_times(neg_times) = [];


subplot(2,1,1);
hold on;
plot(T(sp_times), xfilt(sp_times), '.g', 'LineStyle', 'none');
hold off;

ax(2) = subplot(2,1,2);
bin_sp_train = zeros(1,length(T));
bin_sp_train(sp_times) = 1;
plot(T, bin_sp_train);
linkaxes(ax, 'x');
% %sp_isi = diff(sp_times);
% %peak_isi = diff(loc_times);
% sp_isi = sp_times;
% peak_isi = loc_times;
% 
% n_isi = length(sp_isi);
% plot(1:n_isi, sp_isi, 1:n_isi, peak_isi);
% sp.data = sp_isi;
% sp.FText = 'spikes';
% 
% peaks.data = peak_isi;
% peaks.FText = 'peaks';
% 
% display('Peforming CCM...');
% ccm(sp, peaks, 'dosave', 0);

k = kern(T(1:klength), .02);
analog_sp_train = conv(bin_sp_train, k, 'same');

lfp.data = xfilt(klength/2+1:end);
dind = 1:ccm_resample:length(lfp.data);
lfp.data = lfp.data(dind);
lfp.FText = 'LFP';

sp.data = analog_sp_train(1:(end-klength/2));
sp.data = sp.data(dind);
sp.FText = 'Spikes';

if do_ccm
    display('Peforming CCM...');
    ccm(lfp, sp, 'dosave', 0, 'NSeg', 20);
end


function [k] = kern(t, tau)
neg_ind = find(t < 0);
pos_ind = find(t >= 0);
k = sqrt(2/tau)*exp(-t(pos_ind)/tau);
k = [zeros(1,length(neg_ind)) k];












function [pac pc pac_pc_corr] = pac_pc(ch1, ch2, srate, lfrange, hfrange)

ts = [ch1(:) ch2(:)];

wnumber = 5;
forder = 10000;
ncycles = 5;
wt_scales = linear_scale(lfrange,srate);
T = (0:(length(ts)-1))/srate;
%win = fix(ncycles/mean(lfrange)*srate);
win = srate;
ic = 0;

d = window_FIR(hfrange(1), hfrange(2), srate, forder);
N = d.Numerator;

% Get Hight frequency envelope
parfor i=1:2
    hf_ts(:,i) = filtfilt(N, 1, ts(:,i));
    hf_amp(:,i) = abs(hilbert(hf_ts(:,i)));
    %hf_amp(:,i) = var_windowed(ts(:,i), 100);
end

% Get the wavelet spectrum for the envelopes and LFP
for i=1:2
    hf_amp_wt(:,:,i) = twt(hf_amp(:,i), srate, wt_scales, wnumber);
    lf_wt(:,:,i) = twt(ts(:,i), srate, wt_scales, wnumber);
end


% loop over the frequncies and compute PAC and PC
for i=1:length(lfrange)
    [pc(i,:), pc_angle(i,:)] = phase_coh(lf_wt(i,:, 1), lf_wt(i,:,2),...
        lfrange(i), ncycles, srate, ic);
    
    [pac(i,:, 1), pac_angle(i,:, 1)] = phase_coh(hf_amp_wt(i,:, 1), lf_wt(i,:, 1),...
        lfrange(i), ncycles, srate);
    
    [pac(i,:, 2), pac_angle(i,:, 2)] = phase_coh(hf_amp_wt(i,:, 2), lf_wt(i,:, 2),...
        lfrange(i), ncycles, srate);
    
    pac_pc(i,:,1) = pearson_corr(pc(i,:),pac(i,:,1), win);
    pac_pc(i,:,2) = pearson_corr(pc(i,:),pac(i,:,2), win);
end

pad = lfrange(1)/2;
tp = find(T >= pad & T < (T(end)-pad));
tplot = T(tp);

figure(1);clf;
ax(1) = subplot(5,1,1);
imagesc(tplot,lfrange,fisherZ(pc(:,tp)))
shading flat;
axis([tplot(1) tplot(end) lfrange(1) lfrange(end) zlim]);
caxis([0 2]);
view(0,90);
xlabel('Time (s)');
ylabel('Freq (Hz)');
title('Phase coherence');
set(gca, 'YScale', 'log');

ax(2) = subplot(5,1,2);
imagesc(tplot,lfrange,fisherZ(squeeze(pac(:,tp,1))))
shading flat;
axis([tplot(1) tplot(end) lfrange(1) lfrange(end) zlim]);
caxis([0 2]);
view(0,90);
xlabel('Time (s)');
ylabel('Freq (Hz)');
title('PAC Channel 1');
set(gca, 'YScale', 'log');


ax(3) = subplot(5,1,3);
imagesc(tplot,lfrange,fisherZ(squeeze(pac(:,tp,2))))
shading flat;
axis([tplot(1) tplot(end) lfrange(1) lfrange(end) zlim]);
caxis([0 2]);
view(0,90);
xlabel('Time (s)');
ylabel('Freq (Hz)');
title('PAC Channel 2');
set(gca, 'YScale', 'log');

% PAC-PC Plots

ax(4) = subplot(5,1,4);
imagesc(tplot,lfrange,fisherZ(squeeze(pac_pc(:,tp,1))))
shading flat;
axis([tplot(1) tplot(end) lfrange(1) lfrange(end) zlim]);
caxis([0 2]);
view(0,90);
xlabel('Time (s)');
ylabel('Freq (Hz)');
title('PAC-PC Channel 1');
set(gca, 'YScale', 'log');

ax(5) = subplot(5,1,5);
imagesc(tplot,lfrange,fisherZ(squeeze(pac_pc(:,tp,2))))
shading flat;
axis([tplot(1) tplot(end) lfrange(1) lfrange(end) zlim]);
caxis([0 2]);
view(0,90);
xlabel('Time (s)');
ylabel('Freq (Hz)');
title('PAC-PC Channel 2');
set(gca, 'YScale', 'log');

linkaxes(ax, 'xy');

%PLot the correlations
figure(2);clf;

r = 0:srate:length(ts);
ind = [(r(1:end-1)+1)' r(2:end)'];

for f=1:length(lfrange)
    for b=1:length(ind)
        mpc(b) = mean(pc(f,ind(b,1):ind(b,2)));
        mpac1(b) =  mean(squeeze(pac(f,ind(b,1):ind(b,2),1)));
        mpac2(b) =  mean(squeeze(pac(f,ind(b,1):ind(b,2),2))); 
    end
    pac_pc_corr(f,1) = corr(mpc', mpac1', 'type', 'Spearman');
    pac_pc_corr(f,2) = corr(mpc', mpac2', 'type', 'Spearman');
    
end

plot(lfrange, pac_pc_corr);
axis([lfrange(1) lfrange(end) 0 1])
title('PAC-PC corr');
legend({'Ch1', 'Ch2'});
xlabel('Frequency Hz');
ylabel('PAC-PC corr');
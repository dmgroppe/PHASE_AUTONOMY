function [R, sync, amps, ampcorr] = sync_power(EEG, ch, frange, cond, slength, ptname, atype, window, doplot)

eDir = get_export_path_SMA();
%window = 500;

[tstart tend] = get_trange(cond, slength, ptname);
subr = get_subregion(EEG, tstart, tend);
subr = subr(ch,:);

d = window_FIR(frange(1), frange(2), EEG.srate);
h1 = hilbert(filtfilt(d.Numerator,1,subr(1,:)));
h2 = hilbert(filtfilt(d.Numerator,1,subr(2,:)));

if doplot
    h = figure(1);
    clf;
end

[R, sync, amps, ampcorr] = sync_power_corr(h1, h2, window, sync_fh(atype), doplot);
set(0,'RecursionLimit',length(sync)*2);

if doplot
    text = sprintf('Ch %d vs Ch%d', ch(1), ch(2));
    set(h, 'Name', text);
    subplot(3,1,1);
    title(text);
    save_figure(h,eDir, ['Sync_Power ' text]);
    
    figure(2);
    subplot(2,1,1);
    [R.b(4,:), R.stats(4,:), R.yfit(4,:)] = corr_plot(amps(1,:), amps(2,:));    
    [rho, pval] = corr(amps(1,:)',amps(2,:)','type','Spearman');
    R.S(4).rho = rho;
    R.S(4).pval = pval;
    
    legend(sprintf('R = %6.4f, p = %6.4f', rho, pval));
    title(sprintf('Epoch averages, window = %d, nepochs = %d', window, length(sync)));
    xlabel(sprintf('CH %d',ch(1)));
    ylabel(sprintf('CH %d',ch(2)));
    
    % Amplitude correlations of unfiltered raw time-series
    raw_amps = corr_ts_shift(subr(1,:), subr(2,:), window, 0);
    subplot(2,1,2);
    [R.b(5,:), R.stats(5,:), R.yfit(5,:)] = corr_plot(raw_amps(1,:), raw_amps(2,:));
    [rho, pval] = corr(raw_amps(1,:)',raw_amps(2,:)','type','Spearman');
    R.S(5).rho = rho;
    R.S(5).pval = pval;
    
    legend(sprintf('R = %6.4f, p = %6.4f', rho, pval));
    title(sprintf('Unfiltered TS, window = %d, nepochs = %d', window, length(sync)));
    xlabel(sprintf('CH %d',ch(1)));
    ylabel(sprintf('CH %d',ch(2)));
%     

%     stats = corr_plot(subr(1,:), subr(2,:));
%     legend(sprintf('R = %6.4f, p = %6.4f', stats(1), stats(3)));
%     title(sprintf('Raw time series, window = %d, nepochs = %d', window, length(sync)));
%     xlabel(sprintf('CH %d',ch(1)));
%     ylabel(sprintf('CH %d',ch(2)));
end


function [amp] = corr_ts_shift(x1, x2, window, shift)
index = 1:window:length(x1);
ranges = [index(1:end-1)',index(2:end)'-1];
for i=1:length(ranges)
    amp(1,i) = mean(x1(ranges(i,1):ranges(i,2)));
    amp(2,i) = mean(x2(ranges(i,1):ranges(i,2)));
end





% 
% 
% phases = [-1.7 -pi/4 0 pi/4 1.3];
% 
% for i=1:length(phases)
%     p{i} = phase_amp_rel(h1, h2, 10, phases(i), .01);
% end
% 
% for i=1:length(phases)
%     fprintf('Phase = %3.2f, amp1 = %6.3f\n', phases(i), mean(p{i}.amp1));
%     fprintf('Phase = %3.2f, amp2 = %6.3f\n', phases(i), mean(p{i}.amp2));
%     fprintf('\n');
% end
% 
% for i=1:length(phases)
%     for j=i+1:length(phases)
%         [~,pval] = ttest2(p{i}.amp1, p{j}.amp1);
%         fprintf('Amp1, %3.2f vs %3.2f, p = %6.4f\n', phases(i), phases(j), pval);
%         [~,pval] = ttest2(p{i}.amp2, p{j}.amp2);
%         fprintf('Amp2, %3.2f vs %3.2f, p = %6.4f\n', phases(i), phases(j), pval);
%         fprintf('\n');
%     end
% end


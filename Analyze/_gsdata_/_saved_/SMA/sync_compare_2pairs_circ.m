function [p] = sync_compare_2pairs_circ(EEG, p1, p2)

% USAGE: sync_compare_2pairs_circ(EEG, p1, p2, ap)
%
% Computes significance between channel pairs by partioning the epoch
% in to sub-epochs which are specified in ap.  The synchronization is
% computed for specified frequencies for each epochs and compared using K-S to obtain p-values, which
% are then fdr corrected to determine significance.

channels(:,1) = p1;
channels(:,2) = p2;
npairs = 2;
ap = sync_params();


if numel(ap.condlist) < 2
    display('Need one condition per pair for analysis');
    return;
else
    [t(1,1), t(2,1)] = get_trange(ap.condlist{1}, ap.length, ap.ptname);
    [t(1,2), t(2,2)] = get_trange(ap.condlist{2}, ap.length, ap.ptname);
    t = t/1000*EEG.srate;
end

for i=1:npairs
          
    x = EEG.data(channels(1,i), t(1,i):t(2,i));
    
    if i==2 && ap.surr
        x = rand_rotate(x);
    end
    
    %fprintf('\nComputing wavelet transform for channel #%d', i);
    wt = twt(x, EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);
    h(:,:,2*i-1) = wt';
    
    x = EEG.data(channels(2,i), t(1,i):t(2,i));
    
    %fprintf('\nComputing wavelet transform for channel #%d', i);
    wt = twt(x, EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);
    h(:,:,2*i) = wt';
    
    
end

p11 = find(channels == p1(1));
p12 = find(channels == p1(2));
p21 = find(channels == p2(1));
p22 = find(channels == p2(2));


%phi1 = angle(h(:,:, find(channels == p1(1)))) - angle(h(:,:, find(channels == p1(2))));
%phi2 = angle(h(:,:, find(channels == p2(1)))) - angle(h(:,:, find(channels == p2(2))));


N = fix(ap.length/ap.loom_window*1000);
fh = sync_fh(ap.atype);

% Cycle over the frequencies
for i=1:length(ap.freqs)
    for j=1:N
        % indicies for each epoch
        segstart = (j-1)*ap.loom_window + 1;
        segend = segstart + ap.loom_window -1;
        
        % Compute the specified synchronization measure
        sync1(i,j) = fh(h(segstart:segend,i,1), h(segstart:segend,i,2));
        sync2(i,j) = fh(h(segstart:segend,i,3), h(segstart:segend,i,4));
    end
    
    if strcmp(ap.atype, 'ic')
        sync1(i,:) = abs(sync1(i,:));
        sync2(i,:) = abs(sync2(i,:));
    end
    
    %[hks(i),p(i)] = kstest2(sync1(i,:), sync2(i,:));
    [p(i), hks(i)] = ranksum(sync1(i,:), sync2(i,:));
    
end
sig = fdr_vector(p, ap.alpha, ap.fdr_stringent);

% Display the significant ranges if any
sig_ranges_display(sig, ap)

% Display an maxima and their changes
syncs(:,:,1) = sync1;
syncs(:,:,2) = sync2;
maxima_in_ranges(syncs, ap)

hand = figure(1);
clf('reset');
text = sprintf('Two pair sync %s %d-%d, %d-%d',ap.condlist{1}, p1(1), p1(2), p2(1), p2(2));
set(hand, 'Name', text);

ax(1) = subplot(2,1,1);
sync1_mean = mean(sync1, 2);
sync1_sem = sqrt(var(sync1, 0,2)/N)*1.96;

boundedline(ap.freqs, sync1_mean, sync1_sem, 'b', 'transparency', 0.5);
xlabel('Frequency (Hz)');
ylabel(sprintf('%s', upper(ap.atype)));

sync2_mean = mean(sync2, 2);
sync2_sem = sqrt(var(sync2, 0,2)/N)*1.96;
boundedline(ap.freqs, sync2_mean, sync2_sem, 'g', 'transparency', 0.5);
if ~isempty(ap.yaxis)
    axis([ap.freqs(1), ap.freqs(end), ap.yaxis]);
end

legend(sprintf('%d-%d', p1(1), p1(2)), sprintf('%d-%d', p2(1), p2(2)));

ax(2) = subplot(2,1,2);
plot(ap.freqs, sig);
xlabel('Frequency Hz');
ylabel('Sig');

linkaxes(ax, 'x');

save_figure(hand, get_export_path_SMA(), text);




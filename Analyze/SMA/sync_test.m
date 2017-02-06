function [syncs, sem] = sync_test(EEG, cond, chs, frange, w_sizes, atype, surr, doplot)

if nargin < 8; doplot = 0; end;
if nargin < 7; surr = 0; end

nwindows = 10000;

switch 'atype'
    case 'ic'
        doabs = 1;
    otherwise
        doabs = 0;
end
       

[tstart tend] = get_trange(cond, 60);
subr = get_subregion(EEG, tstart, tend);
subr = subr(chs,:);
[~, npoints] = size(subr);
eDir = get_export_path_SMA();

aparams = get_default_params;
aparams.sync.lowcut = frange(1);
aparams.sync.highcut = frange(2);

if surr
    subr(1,:) = rand_rotate(subr(1,:));
end

h = hilberts(subr, EEG.srate,aparams);
fh = sync_fh(atype);

full_sync = fh(h(1,:), h(2,:));
%full_sync = 1;

syncs = zeros(2,length(w_sizes));
w_sync = zeros(1,nwindows);
for i=1:length(w_sizes)
    for j=1:nwindows
        sshift = floor(0.5*rand*(npoints-2*w_sizes(i)))+1;
        w_sync(j) = fh(h(1,sshift:sshift+w_sizes(i)), h(2,sshift:sshift+w_sizes(i)))/full_sync;
        
        if doabs
            w_sync(j) = abs(w_sync(j));
        end
    end
    syncs(:,i) = [mean(w_sync), std(w_sync)];
end
sem = syncs(2,:)/sqrt(nwindows)*1.96;
fprintf('Full sync = %6.4f\n', full_sync);
fprintf('Sync at longest window = %6.4f\n', syncs(1,end));

if doplot

    figure(1);
    w_lengths = w_sizes/EEG.srate*1000; % In ms
    boundedline(w_lengths, syncs(1,:), sem, 'b', 'transparency', 0.5);
    axis([0, w_lengths(end), 0, max(syncs(1,:)+ syncs(2,:))]);

    %plot(w_lengths,syncs);
    xlabel('Window length (ms)')
    ylabel(upper(atype));
    legend('Std dev', 'Mean');

    save([eDir 'sync_test.mat'], 'syncs', 'w_sizes', 'w_lengths');
end

function [EMD] = sync_eemd_allchan(EEG, ptname, channels, cond, atype, dop, dosave)

if nargin < 7; dosave = false; end;
if nargin < 6; dop = false; end;

% Perform empiricle mode decomposition

ap = sync_params();

subr = data_retrieve(EEG, cond, ap.length, ptname);
subr = subr(channels,:);
T = (1:length(subr))/EEG.srate;

d = window_FIR(60, 250, EEG.srate);
for i=1:length(channels)
    tic
    %EMD{i} = eemd(subr(i,:), ap.emd.Nstd, ap.emd.NE);
    EMD{i} = emd(subr(i,:));
    %EMD{i} = filtfilt(d.Numerator, 1, subr(i,:));
    EMD{i} = EMD{i}';
    toc
end

return;

fname = sprintf('EMD - %s %s', upper(ptname), upper(cond));
% if dosave
%     save([get_export_path_SMA fname '.mat'], 'EMD', 'channels', 'subr', 'ap', 'ptname', 'atype');
% end
% 
for i=1:length(channels)
    h = figure(i); 
    set(h, 'Name', fname);
    [nemd(i),~] = size(EMD{i});
    for j=1:nemd(i)
        ax(j) = subplot(nemd(i),1,j);
        plot(T, EMD{i}(j,:));
        mfreq(j,i) = mean(ifreq(EMD{i}(j,:), EEG.srate));
        title(sprintf('C%d - mean frequency = %6.2f', j, mfreq(j,i)), ap.pl.textprop, ap.pl.textpropval);
        set(gca, ap.pl.textprop, ap.pl.textpropval);
    end
    linkaxes(ax, 'x');
    if dosave
        save_figure(h,get_export_path_SMA(), fname);
    end
end

fh = sync_fh(atype);

for i=1:min(nemd)
    esync(i) = abs(fh(hilbert(EMD{1}(i,:)),hilbert(EMD{2}(i,:))));
end

% Compute the bootstrap statistics

if dop
    parfor j=1:ap.nsurr
        esync_surr(:,j) = abs(emd_surr(EMD, atype));
    end

    for j=1:min(nemd)
        p(j) = (length(find(abs(esync_surr(:,j)) > esync(j))) + 1)/(ap.nsurr + 1);
    end
    p
end

h = figure(length(channels) + 1);
fname = sprintf('EMD SYNC %s %s %s %d-%d', upper(ptname), upper(cond), upper(atype), channels(1), channels(2));
set(h,'Name', fname);
bar(esync);
xlabel('IMF#');
ylabel(sprintf('%s', upper(atype)));

if dosave
    save_figure(h,get_export_path_SMA(), fname);
end

if dosave
    fname = sprintf('%s %s EEMD.mat', upper(ptname), upper(cond));
    save([get_export_path_SMA() fname], 'EMD', 'subr', 'channels', 'ptname', 'mfreq', 'esync', 'esync_surr');
end


function [esync_surr] = emd_surr(EMD, atype)
fh = sync_fh(atype);
[nemd,~] = size(EMD{1});
for j=1:nemd
        esync_surr(j) = fh(hilbert(rand_rotate(EMD{1}(j,:))), hilbert(EMD{2}(j,:)));
end
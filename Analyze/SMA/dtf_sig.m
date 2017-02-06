function [] = dtf_sig(EEG, channels, ptname, cond, freqs, dosave)

if nargin < 6; dosave = 0; end

% DTF comput

ap = sync_params();

% Get the data
[tstart tend] = get_trange(cond, ap.length, ptname);
subr = get_subregion(EEG, tstart, tend);
subr = subr(channels,:)';

[npoints, nchan] = size(subr);
nfreq = length(freqs);

% Set some params for parallel processing
order = ap.dtf.order;
srate = EEG.srate;
f1 = freqs(1);
f2 = freqs(end);
if ap.dtf.window
    windows = 1:ap.dtf.window:npoints;
    wi = [windows(1:end-1)' windows(2:end)'-1];
    nwindows = size(wi,1);
end

% Compute the DTF

if ~ap.dtf.window
    dtf = DTF(subr,freqs(1),freqs(end),ap.dtf.order,EEG.srate);
else
    dtf = zeros(nchan, nchan, nfreq);
    for i=1:nwindows
        dtf = dtf + DTF(subr(wi(i,1):wi(i,2),:),freqs(1),freqs(end),ap.dtf.order,EEG.srate);
    end
    dtf = dtf/nwindows;
end

dtf_surr = zeros(ap.nsurr, nchan, nchan, nfreq);

% Compute the surrogates

parfor i=1:ap.nsurr
    [newts] = make_surr_ts(subr);
    dtf_surr(i,:,:,:) = DTF(newts,f1,f2,order,srate);
end

% Count the number of surrogates greater than the DTF
counts = zeros(nchan, nchan, nfreq);
for i=1:ap.nsurr
    counts = counts + (squeeze(dtf_surr(i,:,:,:)) > dtf);
end

% P-value
p = (counts+1)/(ap.nsurr+1);

% FDR correction
sig = zeros(nchan, nchan, nfreq);
for i=1:nchan
    for j = 1:nchan
        sig(i,j,:) = fdr_vector(squeeze(p(i,j,:)), ap.alpha, ap.fdr_stringent);
    end
end

% Set diagonals to zero
for i=1:nchan
    dtf(i,i,:) = 0;
end

% Compute the normalization
sdtf = dtf/(max(max(max(dtf))));


% Plot the results
h = figure(1);
clf('reset');
fname = sprintf('DTF SIG %s %s', upper(ptname), upper(cond));
set(h, 'Name', fname);

count = 0;
np = nchan*(nchan-1)/2;
c = ceil(sqrt(np));
if mod(np,c) == 0
    r = np/c;
else
    r = c;
end

for i=1:nchan
    for j=i+1:nchan
        if i~= j
            count = count + 1;
            subplot(r, c,count);
            plot_dtf(sdtf,sig,i,j, channels, freqs)
        end
    end
end

if dosave
    save_figure(h, get_export_path_SMA(), fname);
end

% h = figure(2);
% fname = sprintf('DTF NORM to MAX SIG %s %s', upper(ptname), upper(cond));
% set(h, 'Name', fname);

% An attempt at normalizing the forward and backward flows - not helpful

% count = 0;
% for i=1:nchan
%     for j=i+1:nchan
%         if i~= j
%             fmax = max(dtf(j,i,:));
%             bmax = max(dtf(i,j,:));
%             if fmax > bmax
%                 ndtf = dtf(i,j,:)./dtf(j,i,:);
%                 yl = 'bmax/fmax';
%             else
%                 ndtf = dtf(j,i,:)./dtf(i,j,:);
%                 yl = 'fmax/bmax';
%             end
%             count = count + 1;
%             subplot(r, c,count);
%             plot(freqs, squeeze(ndtf))
%             xlabel('Frequency(Hz)')
%             ylabel(yl);
%             legend(sprintf('%d->%d', channels(i), channels(j)));
%             axis([freqs(1) freqs(end) 0 1]);
%         end
%     end
% end




% Make surrogate time series by scrambling the phases
function [newts] = make_surr_ts(ts)

nchan = size(ts,2);
newts = ts;
for j=1:nchan
%     Y = fft(ts(:,j));
%     Pyy = sqrt(Y.*conj(Y));
%     Phyy = Y./Pyy;
%     index = 1:size(ts,1);
%     index = surrogate(index);
%     Y = Pyy.*Phyy(index);
%     newts(:,j) = real(ifft(Y));
    newts(:,j) = rand_rotate(ts(:,j));
end

% plot the results
function [] = plot_dtf(dtf,sig,i,j, channels, freqs)

ap = sync_params();

plot(freqs, squeeze(dtf(j,i,:)), freqs, squeeze(dtf(i,j,:)));

l1 = sprintf('%d->%d', channels(i), channels(j));
l2 = sprintf('%d->%d', channels(j), channels(i));

if isempty(ap.yaxis)
    ymax = max(max([dtf(j,i,:) dtf(i,j,:)]));
    axis([freqs(1) freqs(end) 0 ymax]);
else
    axis([freqs(1) freqs(end) ap.yaxis]);
    ymax = max(ap.yaxis);
end

legend({l1 l2});

hold on
plot(freqs, squeeze((sig(j,i,:)))*ymax/2, 'b');
plot(freqs, squeeze((sig(i,j,:)))*ymax/3, 'g');
hold off

xlabel('Frequency (Hz)');
ylabel('Normalized DTF');
set(gca, 'TickDir', 'out');




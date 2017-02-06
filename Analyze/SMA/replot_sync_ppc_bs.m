function [] = replot_sync_ppc_bs(ptname, cond, ch, dosave)

% Replots PPC for a single channel pair for a specfic condition

if nargin < 4; dosave = 0; end;

ap = sync_params();

Dirs ={'D:\Projects\Data\Vant\Figures\Super\PhasePowerCorr\Vant\',...
    'D:\Projects\Data\Vant\Figures\Super\PhasePowerCorr\Nourse\'};

subdirs = sub_dirs(Dirs);
R = [];
surr_amp = [];

for i=1:numel(subdirs)
    fname = sprintf('PPC BS %s %s %d-%d SURR', upper(ptname), upper(cond), ch(1), ch(2));
    full_path = [subdirs{i} fname '.mat'];
    if exist(full_path, 'file');
        load(full_path);
        break;
    end
end

if isempty(surr_amp)
    display('Unable to find specified file.');
    return;
end

%% Compute the probabilities
counts = zeros(1,length(ap.freqs));

for i=1:length(ap.freqs)
    index = find(surr_amp(i,:) > amps(i));
    counts(i) = length(index);
end

nsurr = size(surr_amp,2);
p = (1+counts)./(nsurr+1);
sig = fdr_vector(p, ap.alpha, ap.fdr_stringent);

% Limit to a certain number of contiguous frequencies
[~,sig] = sig_to_ranges(sig, ap.freqs, ap.minr);

%% Plot the PPC matrix

%% PLot the figures
h = figure(1);
fname = sprintf('PPC BS %s %s %d-%d', upper(ptname), upper(cond), ch(1), ch(2));
set(h,'Name', fname);
ax(1) = subplot(2,1,1);
labels.x = 'Freqs';
labels.y = 'Power correlations';
labels.title = fname;
plot_xy(ap.freqs, amps, labels, ap.yaxis);
hold on
plot(ap.freqs, mean(surr_amp,2), 'g');
hold off
legend({'Amps', 'Surrogates'});
set(gca,'TickDir', 'out');

if ~isempty(ap.yaxis)
    plot_ranges(ap.extrema_range, ap.yaxis, 'vert');
else
    plot_ranges(ap.extrema_range, [0 1], 'vert');
end

ax(2) = subplot(2,1,2);
labels.y = 'Sig';
plot_xy(ap.freqs, sig, labels,[0 1]);

linkaxes(ax, 'x');
set(gca,'TickDir', 'out');

if dosave
    save_figure(h,get_export_path_SMA(), ['REPLOT ' fname]);
end

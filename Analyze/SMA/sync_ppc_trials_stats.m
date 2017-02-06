function [] = sync_ppc_trials_stats(p1, p2, condlist, ptname, dosave, surr)

if nargin < 5; dosave = 0; end;
if nargin < 6; surr = 0; end;

Dirs ={'D:\Projects\Data\Vant\Figures\Super\PhasePowerCorr\Vant\',...
    'D:\Projects\Data\Vant\Figures\Super\PhasePowerCorr\Nourse\'};

subdirs = sub_dirs(Dirs);
ap = sync_params();

R1 = get_trial_file(ptname, condlist{1}, p1, subdirs);

% Load the surrogate file as the second if specified
if surr
    R2 = get_trial_file(ptname, condlist{2}, p2, subdirs, 1);
else
    R2 = get_trial_file(ptname, condlist{2}, p2, subdirs);
end

if isempty(R1) || isempty(R2)
    display('One or both of the files could not be load.');
    return;
end

%R1.rho(:,:,13) = [];
%R2.rho(:,:,13) = [];
A1 = get_trial_amps(R1);
A2 = get_trial_amps(R2);
% zindex = find(R1.x == 0);
% A1 = R1.rho(:,:,zindex);
% A2 = R2.rho(:,:,zindex);


for i=1:length(R1.ap.freqs)
    X1 = A1(i,:);
    X2 = A2(i,:);
    p(i) = ranksum(X1, X2);
end

h = figure(1);
fname = sprintf('PPC Trial Stats %s %s-%s %d-%d %d-%d',upper(ptname), upper(condlist{1}),...
    upper(condlist{2}), p1(1), p1(2), p2(1), p2(2));
set(h, 'Name', fname)
ax(1) = subplot(2,1,1);
plot(R1.ap.freqs, mean(A1,2), R1.ap.freqs,mean(A2,2));
xlabel('Frequency Hz');
ylabel('Power Corr');
set(gca, 'TickDir', 'out');


if ~isempty(ap.yaxis)
    plot_ranges(ap.extrema_range, ap.yaxis, 'vert');
    yaxis = ap.yaxis;
else
    ma1 = mean(A1,2);
    ma2 = mean(A2,2);
    
    yaxis = [min([min(ma1) min(ma2)]) max([max(ma1) max(ma2)])];
    plot_ranges(ap.extrema_range, yaxis, 'vert');
end
axis([R1.ap.freqs(1) R1.ap.freqs(end) yaxis]);

ax(2) = subplot(2,1,2);
sig = fdr_vector(p,ap.alpha, ap.fdr_stringent);
[~,rsig] = sig_to_ranges(sig, R1.ap.freqs, ap.minr);
plot(R1.ap.freqs, rsig);
xlabel('Frequency Hz');
ylabel('Significance');

if dosave
    save_figure(h, get_export_path_SMA(), fname);
end

% Plot the average of the two
h= figure(2);
f2name = [fname ' PPCs'];
set(h, 'Name', f2name);
subplot(2,1,1);
plot_ppc(R1.x, mean(R1.rho,3), R1.ap);
title(upper(condlist{1}));

subplot(2,1,2);
plot_ppc(R2.x, mean(R2.rho,3), R2.ap);
title(upper(condlist{2}));

if dosave
    save_figure(h, get_export_path_SMA(), f2name,0);
end




function [R] = get_trial_file(ptname, cond, ch, subdirs, surr)

if nargin < 5; surr = 0; end;

R = [];

for i=1:numel(subdirs)
    if surr
        fname = sprintf('PPC TRIALS SURR %s %s %d&%d', upper(ptname), upper(cond), ch(1), ch(2));
    else
        fname = sprintf('PPC TRIALS %s %s %d&%d', upper(ptname), upper(cond), ch(1), ch(2));
    end
    full_path = [subdirs{i} fname '.mat'];
    if exist(full_path, 'file');
        load(full_path);
    end
end

if isempty(R)
    display(fname);
    display('Unable to find this file.');
    return;
end

function [amps] = get_trial_amps(R)

ntrials = size(R.rho, 3);
x = R.x;
rho = R.rho;
freqs = R.ap.freqs;
parfor i=1:ntrials
    amps(:,i) = sync_ppc_amps(x, rho(:,:,i));
end
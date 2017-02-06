function [] = replot_sync_ppc(ptname, cond, ch, dosave)

% Replots PPC for a single channel pair for a specfic condition

if nargin < 4; dosave = 0; end;

Dirs ={'D:\Projects\Data\Vant\Figures\Super\PhasePowerCorr\Vant\',...
    'D:\Projects\Data\Vant\Figures\Super\PhasePowerCorr\Nourse\'};

subdirs = sub_dirs(Dirs);
R = [];
ap = sync_params();

for i=1:numel(subdirs)
    fname = sprintf('Phase-power corr %s %s %d&%d', upper(ptname), upper(cond), ch(1), ch(2));
    full_path = [subdirs{i} fname '.mat'];
    if exist(full_path, 'file');
        load(full_path);
    end
end

if isempty(R)
    display('Unable to find specified file.');
    return;
end

%% Get sig, fdr, colorize, remove noncontiguous regions etc...
crho = ppc_sig(R.rho,R.p, ap);

h = figure(1);
clf('reset');
fname = sprintf('REPLOT Phase-power corr %s %s %d&%d', upper(ptname), upper(cond), ch(1), ch(2));
set(h, 'Name', fname);

R.ap.pl = ap.pl;
R.ap.yaxis = ap.yaxis;
plot_ppc(R.x, crho, R.ap);

if dosave
    save_figure(h, get_export_path_SMA(), fname);
end


%% Replot the phase information
h = figure(2);
clf('reset');
f2name = [fname ' GOOD'];
set(h, 'Name', f2name);
plot_ppc_angles(R.mean_angle, R.ap);

if dosave
    save_figure(h, get_export_path_SMA(), f2name);
end

%% PLOT the zero phase CORR value
h = figure(3);
clf('reset');
f3name = [fname, ' ZERO'];
set(h, 'Name', f3name);
label.x = 'Frequency';
label.y = 'Power Corr';
label.title = 'Power Corr at GOOD phase';

zindex = find(R.x == 0);
plot_xy(R.ap.freqs, crho(:,zindex), label, ap.yaxis);

if dosave
    save_figure(h, get_export_path_SMA(), f3name);
end

%% PLOT CORR along phase-axis at peak CORR

h = figure(4);
clf('reset');
f4name = [fname, ' PEAK CORR'];
set(h, 'Name', f4name);

rhomax = max(crho(:,zindex));
findex = find(crho(:,zindex) == rhomax);
plot(R.x, crho(findex,:), '.k',...
    'LineStyle', 'none', 'MarkerSize', 15);
xlabel('Good Phase');
ylabel('Power Corr');
title('Frequency Corr at peak');

beta = nlinfit(R.x,crho(findex,:),@gauss_fit,[0.5 0]);
pfit = gauss_fit(beta,R.x(1):.1:R.x(end));
hold on;
plot(R.x(1):.1:R.x(end), pfit);
hold off;

ltext{1} = sprintf('\nRho max = %6.2f\n', rhomax);
ltext{2} = sprintf('\nFrequency at which this max occurs = %6.2f\n', R.ap.freqs(findex));
legend(ltext);

if dosave
    save_figure(h, get_export_path_SMA(), f4name);
end

%% Calculate the mean time lag over the various ranges
nranges = size(ap.extrema_range, 2);
time_delay = R.mean_angle/(2*pi)./R.ap.freqs*1000;

fprintf('\nTime delays over specific frequency ranges:')
for i=1:nranges
    ind = find(R.ap.freqs >= ap.extrema_range(1,i) & R.ap.freqs <= ap.extrema_range(2,i));
    meandelay = mean(time_delay(ind));
    semdelay = var(time_delay(ind))/sqrt(numel(ind));
    fprintf('\nRange 1 %d-%d', ap.extrema_range(1,i), ap.extrema_range(2,i));
    fprintf('\n  Delay = %6.2f +- %6.2e ms', meandelay, semdelay);
end
fprintf('\n');

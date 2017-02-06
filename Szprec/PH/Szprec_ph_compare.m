function [] = Szprec_ph_compare(save_figs)

% Compares the early to max analysis
% Plots the collpased normalized time vs. seizure number graph for the
% 'early' analysis

if nargin < 1; save_figs = 0; end;

global DATA_PATH;
global FIGURE_DIR;

[sznames] = sz_list_load();
if isempty(sznames)
    return;
end

all_e_values = [];
all_m_values = [];
%% Correlation of times by different methods
for i=1:numel(sznames)
    pt_name = strtok(sznames{i}{1}, '_');

    Rm{i} = get_R(DATA_PATH, pt_name, 'max', sznames{i});
    Re{i} = get_R(DATA_PATH, pt_name, 'early', sznames{i});

    m_ind = find(isnan(Rm{i}.plot_values) == 0);
    e_ind = find(isnan(Re{i}.plot_values) == 0);

    v = intersect(m_ind, e_ind);

    h = figure; clf;
    fname = sprintf('%s_PH_Comparison', pt_name);
    set(h, 'name', fname);
    plot_with_corr(Re{i}.plot_values(v), Rm{i}.plot_values(v));
    xlabel('Early');
    ylabel('Max');
    
    all_e_values = [all_e_values Re{i}.plot_values(v)'];
    all_m_values = [all_m_values Rm{i}.plot_values(v)'];
    
    if save_figs
        save_figure(gcf, FIGURE_DIR, fname, 1);
    end
end
%% Plot combined values

h = figure; clf;
fname ='PH_Early_Max_ALL VALUES';
set(h, 'name', fname);
plot_with_corr(all_e_values, all_m_values);
xlabel('Early');
ylabel('Max');

if save_figs
    save_figure(gcf, FIGURE_DIR, fname, 1);
end

%% Compute the correlation between seizure number and onset time for all
% patients and all seizures

all_n_sz = [];
all_pv = [];
for i=1:numel(sznames)
    all_n_sz = [all_n_sz Re{i}.n_sz'];
    all_pv = [all_pv Re{i}.plot_values'];
end

ind = find(isnan(all_pv) == 0);

h = figure;clf;
fname = sprintf('%s_PH_NSz_SzTime', pt_name);
set(h, 'Name', fname);
plot(all_n_sz(ind), all_pv(ind), '.', 'LineStyle', 'none', 'MarkerSize', 15);

[r, p] = corr(all_n_sz(ind)', all_pv(ind)', 'type', 'Spearman');
title(sprintf('r = %6.4e, p = %6.4e', r, p));
xlabel('Numer of seizures detected');
ylabel('Standardized onset time');
set(gca, 'TickDir', 'out');
axis([0 max(all_n_sz)+1 ylim]);

% beta = nlinfit(all_n_sz(ind), all_pv(ind), @d_fit, [1,1,nanmin(all_pv)]);
% xfit = 1:0.1:max(all_n_sz);
% yfit = d_fit(beta, xfit);

hold on;
%plot(xfit, yfit, 'c', 'Linewidth', 2);

for i=1:max(all_n_sz);
    ind = find(all_n_sz == i);
    p_median(i) = nanmedian(all_pv(ind));
end
plot(1:max(all_n_sz), p_median, '.m', 'LineStyle', 'none', 'MarkerSize', 25);

% t = sprintf('%6.2fexp^{-x/%6.2f}+%6.2f', beta);
% text(mean(xlim)-2, mean(ylim), t, 'FontSize', 10);

hold off;

if save_figs
    save_figure(gcf, FIGURE_DIR, fname, 1);
end


function [R] = get_R(DATA_PATH, pt_name, atype, sznames)
f = fullfile(DATA_PATH, 'Szprec', pt_name, '\Processed\Adaptive deriv',...
        [pt_name '_PH_Summary_' atype '.mat']);
if ~exist(f, 'file')
    R = Szprec_ph_stats(sznames, atype);
else
    load(f);
end

function [] = plot_with_corr(x,y)
x = x(:);
y = y(:);
plot(x, y, '.', 'LineStyle', 'none', 'MarkerSize', 15);
set(gca, 'TickDir', 'out');

[r, p] = corr(x, y, 'type', 'Spearman');
title(sprintf('r = %6.4f, p = %6.4e', r, p));
axis([0 1 0 1]);


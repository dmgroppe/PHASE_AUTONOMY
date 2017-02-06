function [] = peds_all(doplot)

if nargin <1; doplot = 0; end;

cases = [2 6];

for i=1:length(cases)
    [amps{i} tintervals{i} rho{i}, p{i}] = peds(cases(i), [60 200]);
end


if doplot

    h = figure(1);
    fname = 'Pediatric Power frequency correlation';
    set(h, 'Name', fname);
    sync_pfc_plot(amps, tintervals, [0 30], [0 25]);
    title('Pediatric ECoG');

    [rho, p] = corr(amps',tintervals','type','Spearman');
    ltext = sprintf('R = %4.2f, p = %4.2e', rho,p);
    legend(ltext);

    if dosave
        save_figure(h, get_export_path_SMA(), fname);
    end

    h = figure(2);
    f2name = [fname ' HISTOS'];
    set(h,'Name', f2name);
    subplot(2,1,1);
    hist(tintervals,bins);
    xlabel(' Interval (ms)');
    ylabel('Counts')

    subplot(2,1,2);
    hist(amps,bins);
    xlabel(' Amps (uV)');
    ylabel('Counts');
end
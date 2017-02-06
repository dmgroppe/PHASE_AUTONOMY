function [] = plot_results(spectra, params, frq, nfig)

% Plot the time frequency stuff

h = figure(nfig);
set(h, 'Name', upper(sprintf('%s CH%d, TF', params.export.prefix,  params.ana.ch_analyzed)));
plot_tf(spectra, frq, params.data.srate, params);

% Plot the cross-frequency modulation

h = figure(nfig+1);
set(h, 'Name', upper(sprintf('%s, CH%d, Modulation', params.export.prefix,  params.ana.ch_analyzed)));
display('Computing cross-frequency modulation...');
blsamples = time_to_samples(params.ana.baseline, params.data.srate);
sub_spectra = spectra(:,blsamples:end,:);
[mp ms] = cross_freq_mod(sub_spectra);
plot_cfmodulation(mp, ms, params, frq);
clear('sub_spectra');

if (params.pl.inclplcalcs)
    display('Computing PL statistics...');
    pl = pl_matrix(length(frq), length(spectra),params.pl.bins);
    for p=1:total_epochs_analzed
        pl = set_pl_matrix(pl, spectra(:,:,p));
    end
    pl_stats = get_pl_stats(pl, params.pl.probbins, params.pl.steps);

    % Remove this object, since it is very large
    clear('pl');

    h = figure(nfig+3);
    set(h, 'Name', 'PL statistics (normalized)');
    plot_spectrum(pl_stats, frq, params.data.srate, params);
end
function [combined] = combine_analyses(inDir, fn1, fn2)

f1 = [inDir fn1 '.mat'];
f2 = [inDir fn2 '.mat'];

combined = cell(1,2);

if (~exist(f1, 'file') || ~exist(f2, 'file'))
    display('One or more files does not exist');
    return
end

load(f1);
combined{1}.spectra = spectra;
combined{1}.params = params;
combined{1}.frq = frq;

if (params.pl.inclplcalcs)
    combined{1}.pl_stats = pl_stats;
end

load(f2);
combined{2}.spectra = spectra;
combined{2}.params = params;
combined{2}.frq = frq;

if (params.pl.inclplcalcs)
    combined{2}.pl_stats = pl_stats;
end

clear('spectra');

%plot_results(combined{1}.spectra, combined{1}.params, combined{1}.frq, 1);
%plot_results(combined{2}.spectra, combined{2}.params, combined{2}.frq, 3);

h = figure(1);
set(h, 'Name', fn1);
plot_tf(combined{1}.spectra, frq, params.data.srate, params, 300);

h = figure(2);
set(h, 'Name', fn2);
plot_tf(combined{2}.spectra, frq, params.data.srate, params, 300);

blsamples = time_to_samples(params.ana.baseline, params.data.srate)+1;

sub_spectra = cell(1,2);
sub_spectra{1} = combined{1}.spectra(:,blsamples:end,:);
sub_spectra{2} = combined{2}.spectra(:,blsamples:end,:);

display('Computing modulation...');
[mp1 ms1] = cross_freq_mod(sub_spectra{1});
[mp2 ms2] = cross_freq_mod(sub_spectra{2});


h = figure(3);
ft = sprintf('%s - Modulation', fn1);
set(h, 'Name', ft);
plot_cfmodulation(mp1, ms1, params, frq);

h = figure(4);
ft = sprintf('%s - Modulation', fn2);
set(h, 'Name', ft);
plot_cfmodulation(mp2, ms2, params, frq);

%{
mp = zeros(length(frq), length(frq));
display('Computing modulation phase over all trials...');
for i=1:2
    [nfreq npoints nspectra] = size(sub_spectra{i});
    for j=1:nspectra
        mp = mp + mod_phase(sub_spectra{i}(:,:,j));
    end
end
mp = mp/nspectra;

mod_stength = cell(1,2);
ms = zeros(length(frq), length(frq));
for i=1:2
    display(sprintf('Computing modulation strength for condition %d...', i));
    [nfreq npoints nspectra] = size(sub_spectra{i});
    for j=1:nspectra
        ms = ms + mod_strength(sub_spectra{i}(:,:,j),mp);
    end
    mod_stength{i} = ms/nspectra;
end

figure(1);
plot_cfmodulation(mp, mod_stength{1}, params, frq);
figure(2);
plot_cfmodulation(mp, mod_stength{2}, params, frq);

%}


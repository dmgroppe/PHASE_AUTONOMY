% USAGE: atten_condition_sig()
%  Computed the bootstrap significance within condition
%  Combined the various trials together first

function [] = atten_collapse_condition(nfig)

aparams = get_default_params();

aparams.ana.subjectname = 'Bonner';
test = 'face';
aparams.ana.cond = 'face';  % Can be face or scene

aparams.ana.test_index = [1 2];
nfiles = length(aparams.ana.test_index);
channel = 9;
nsurr = 100;
incl_pl = 0;

for i=1:length(aparams.ana.test_index)
    aparams.ana.test = sprintf('%s%d', test, aparams.ana.test_index(i));
    aparams = atten_file_names(aparams);
    fn = sprintf('%s%s CH%d.mat', aparams.export.dir, aparams.export.prefix, channel);
    load(fn);
    al_list{i} = alimit_list;
    param_list{i} = params;
    pl_stats_list{i} = pl_stats;
    spectra_list{i} = spectra;
end

total_spectra = 0;
nspeclist = zeros(1,nfiles);
for i=1:nfiles
    [nfrq,npoints,nspectra] = size(spectra_list{i});
    nspeclist(i) = nspectra;
    total_spectra = total_spectra + nspectra;
end

all_spectra = zeros(nfrq,npoints,total_spectra);

for i=1:nfiles
    if (i==1)
        sstart = 1;
        send = nspeclist(1);
    else
        sstart = sum(nspeclist(1:i-1))+1;
        send = sum(nspeclist(1:i));
    end
        
    all_spectra(:,:,sstart:send) = spectra_list{i};
end

R.data.power.mean = mean(abs(all_spectra).^2,3);
R.data.power.std = std(abs(all_spectra).^2,3);

R.data.cvar = abs(sum(all_spectra_spectra,3));

%{
h = figure(nfig);
set(h, 'Name', upper(sprintf('%s %s %s CH%d, TF', aparams.ana.subjectname,  test, aparams.ana.cond, channel)));
plot_tf(all_spectra, frq, param_list{1}.data.srate, param_list{1});

h = figure(nfig+1);
set(h, 'Name', upper(sprintf('%s %s %s CH%d, PL', aparams.ana.subjectname,  test, aparams.ana.cond, channel)));

pl_stats = zeros(nfrq, npoints);
for i=1:nfiles
    pl_stats = pl_stats + (pl_stats_list{i} * nspeclist(i));
end
pl_stats = pl_stats./total_spectra;
plot_spectrum(pl_stats, frq, param_list{1}.data.srate, param_list{1});

%}

psurrogates = zeros(nfrq, npoints, nsurr);
cvsurrogates = zeros(nfrq, npoints, nsurr);
%plsurrogates = zeros(nfrq, npoints, nsurr);
%blsamples = time_to_samples(param_list{1}.ana.baseline, param_list{1}.data.srate);

for i=1:nsurr
    display(sprintf('Iteration %d of %d', i, nsurr));
    slist = floor(rand(1,total_spectra)*total_spectra)+1;
    sub_spectra = all_spectra(:,:,slist);
    
    psurrogates(:,:,i) = mean(abs(sub_spectra).^2,3);
end


R.surr.power.mean = mean(psurrogates, 3);
R.surr.power.std = var(psurrogates, 1, 3);


pl_stats = zeros(nfrq, npoints);
for i=1:nfiles
    pl_stats = pl_stats + (pl_stats_list{i} * nspeclist(i));
end
pl_stats = pl_stats./total_spectra;

pz = mean(abs(all_spectra).^2,3)./pvar;
cvz = abs(sum(all_spectra,3))./cvvar;
%plz = pl_stats./plvar;
plz = pl_stats;

x = get_x(npoints, param_list{1}.data.srate)-param_list{1}.ana.baseline;

h = figure(nfig);
figname = sprintf('%s %s %s CH%d', aparams.ana.subjectname, test, aparams.ana.cond, channel);
set(h, 'Name', figname);
ax(1) = subplot(3,1,1);
labels.x = 'Time (ms)';
labels.y = 'Freq (Hz)';
labels.title = sprintf('Power Z-score');
labels.z.max = max(max(pz));
labels.z.min = min(min(pz));
generic_tf_plot(x, frq, pz, labels);

ax(2) = subplot(3,1,2);
labels.title = sprintf('CVar Z-score');
labels.z.max = max(max(cvz));
labels.z.min = min(min(cvz));
generic_tf_plot(x, frq, cvz, labels);

ax(3) = subplot(3,1,3);
labels.title = sprintf('PL Z-score');
labels.z.max = max(max(plz));
labels.z.min = min(min(plz));
generic_tf_plot(x, frq, plz, labels);

linkaxes(ax, 'xy');





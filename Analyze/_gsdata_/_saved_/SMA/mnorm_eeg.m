function [p] = mnorm_eeg(EEG, ap, dosave)

if nargin < 3; dosave = 0; end;

[tstart tend] = get_trange(ap.condlist{1}, ap.length, ap.ptname);
subr = get_subregion(EEG, tstart, tend);

nchan = size(subr,1)-1;
mn = zeros(1, nchan);

srate = EEG.srate;
lowf = ap.mnorm.lowf;
highf = ap.mnorm.highf;

%ap.alpha = 0.001;

parfor i=1:nchan
    mn(i) = mnorm(subr(i,:), srate, lowf, highf);
end

p = 2*(1-normcdf(mn,0,1));
sig = p <= ap.alpha;

if ap.mnorm.lowf(1) < 1
    lowf1 = 0;
else
    lowf1 = ap.mnorm.lowf(1);
end

fname = sprintf('MNorm %s %4.0f to %4.0fHz with %4.0f to %4.0fHz alpha %4.0f',...
        ap.condlist{1}, lowf1, ap.mnorm.lowf(2), ap.mnorm.highf(1), ap.mnorm.highf(2),...
        ap.alpha*1000);
% nothing significant dont't plot anything
if max(sig) > 0

    h = figure(3);
    clf('reset');
    set(h, 'Name', fname);
    [schematic, elist] = load_electrode_schematic(ap.ptname);
    show_schematic(schematic);
    plot_on_schematic(mn, 1:nchan, elist, [0 max(mn)], sig);

    if dosave
        save_figure(h, get_export_path_SMA(), fname);
    end
else
    fprintf('\n%s...nothing significant.\n', fname);
end
    
function [] =sync_pfc_multichan(EEG, ch, cond, ptname, frange, dosave)

if nargin < 6; dosave = 0; end;

ap = sync_params();
damp = 1; % Amplitude grid size
dint = .5;  % interval grid size


nchan = length(ch);

all_amp = [];
all_intervals = [];

condtext = [];
parfor j=1:numel(cond)
    condition = cond{j};
    for i=1:nchan
        currchan = ch(i);
        [amp intervals] = sync_power_freq_corr(EEG, currchan, condition, ptname, frange);
         all_amp = [all_amp amp];
         all_intervals = [all_intervals intervals];
    end
    condtext = [condtext cond{j}];
end

amps = all_amp;
intervals = all_intervals;
tintervals = intervals/EEG.srate*1000;

[counts, ampbins, intbins] = scatter_to_grid(amps, tintervals, damp, dint, ap.fpc.amprange, ap.fpc.intrange);

ampvals = ampbins(1:end-1) + (ampbins(2)-ampbins(1))/2;
intvals = intbins(1:end-1) + (intbins(2)-intbins(1))/2;

fname = sprintf('PCF MC %s %s %d-%d', upper(ptname), upper(condtext), frange(1), frange(2));
if ap.fpc.revrel
    fname = [fname ' REVEL'];
end
h = figure(1);
set(h, 'Name', fname);

cm = colormap(gray);
colormap(cm(end:-1:1,:));
set(gcf, 'Renderer', 'zbuffer');
surf(ampvals, intvals, counts);
axis([min(ampvals) max(ampvals) min(intvals) max(intvals) min(min(counts)) max(max(counts))]);
view(0,90);
axis square;
shading flat;
xlabel('Amplitude (uV)');
ylabel('Interval (ms)');

set_fa_prop(ap);
caxis([0 max(max(counts))]);

[rho, p] = corr(amps',tintervals','type','Spearman');
display(sprintf('R = %4.2f, p = %e', rho,p));
%legend(ltext);

if dosave
    save_figure(h, get_export_path_SMA(), fname);
end

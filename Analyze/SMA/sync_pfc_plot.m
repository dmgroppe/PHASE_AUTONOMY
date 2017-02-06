function [] = sync_pfc_plot(amps, tintervals, amprange, intrange, damp, dint)

% USAGE: sync_pfc_plot(amps, intervals, srate, damp, dint, amprange, intrange)
ap = sync_params();

if nargin < 6
    dint = 0.5;
end

if nargin < 5
    damp = 1;
end

if nargin < 4
    intrange = [min(intervals) max(intervals)];
end

if nargin < 3
    amprange = [min(amps) max(amps)];
end

[counts, ampbins, intbins] = scatter_to_grid(amps, tintervals, damp, dint, amprange, intrange);

ampvals = ampbins(1:end-1) + (ampbins(2)-ampbins(1))/2;
intvals = intbins(1:end-1) + (intbins(2)-intbins(1))/2;

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

%legend(ltext);
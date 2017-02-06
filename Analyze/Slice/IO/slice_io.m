function [S, spikes, mp] = slice_io(Dir, eDir, fn, ap, dosave)

if nargin < 4; dosave = false; end;

fpath = [Dir fn '.abf'];
if ~exist(fpath, 'file')
    display('File does not exits');
    return;
end

[d,si,hdr]=abfload(fpath);

if hdr.nOperationMode ~= 5
    % Means that data were acquired in some other mode than that required
    % for I/O
    display('Data not acquired in: waveform fixed-length mode');
    return;
end

%------------Compute a few constants -----------------------%

[npoints nchan nepochs] = size(d);
hdr.lNumSamplesPerEpisode = npoints;
hdr.nADCNumChannels = nchan;
hdr.lActualEpisodes = nepochs;
ap.io.maxT = ap.io.pulsestart + ap.io.pulsedur;

sr = 1/(si*1e-6);
T = (si*1e-3)*(0:(hdr.lNumSamplesPerEpisode-1));

% Keep track of th efigures for printing
fcount = 0;
figs = [];

% Plot the raw data
[fcount, figs] = figure_set(fcount, figs, [upper(fn) '-Raw Data']);
for i=1:hdr.nADCNumChannels
    subplot(hdr.nADCNumChannels, 1, i)
    D = squeeze(d(:,i,:));
    plot(T,D(:,[1 end]));
    xlabel('Time(ms)');
    ylabel(hdr.recChUnits{i});
    axis([0 T(end) ap.io.yaxis]);
end

% Create the waveform
[fcount, figs] = figure_set(fcount, figs, [upper(fn) ' Waveform']);
wf = waveform_create(ap, T, size(d,3));
plot(T,wf(:,[1 end]));
ylim([min(ylim)-100 max(ylim) + 100]);

%---------------------- Membrane properties and the like -----------------%
% Get the memobrane properties
[fcount, figs] = figure_set(fcount, figs, [upper(fn) '-Ih Calculation']);
[mp] = membrane_properties(squeeze(d(:, ap.io.ch_to_analyze, :)), hdr, ap, sr);
        
[fcount, figs] = figure_set(fcount, figs, [upper(fn) '-Input resistance']);
plot(mp.pulses(1:length(mp.sag_peak)),mp.sag_peak, '.', 'MarkerSize', 20);
hold on;
plot(mp.xfit, mp.yfit, 'r');
hold off;
title(sprintf('Resistance = %4.0f MOhm Rmp = %4.0fmV', mp.b(2)*1e3, mp.b(1)));

%----------------- Spike analysis ---------------------------------------%

% Find all the spikes
[S] = find_spikes(squeeze(d(:, ap.io.ch_to_analyze, :)), T, ap);

% Store some parameters
S.sr = sr;
S.T = T;
S.hdr = hdr;

% Get plot layout
[r c ] = rc_plot(hdr.lActualEpisodes+1);


% Maybe at some point 2 cells (or more) will be recorded from??
cmap = colormap(lines);

ftext = sprintf('%s-SPIKES Channel # %d',upper(fn), ap.io.ch_to_analyze);
[fcount, figs] = figure_set(fcount, figs, ftext);

for j = 1:hdr.lActualEpisodes
    ax(j) = subplot(r,c,j);
    plot(T,d(:,ap.io.ch_to_analyze,j));
    xlabel('Time(ms)', 'FontSize', 6);
    ylabel(hdr.recChUnits{ap.io.ch_to_analyze}, 'FontSize', 6);
    axis([0 T(end) ap.io.yaxis]);
    
    % Plot the peaks
    if ~isempty(S.pks{j})   
        hold on;
        plot(T(S.locs{j}), S.pks{j}, '.r', 'LineStyle', 'none');
        hold off;
    end
    lv(j) = locVar(T, S.locs{j}, ap);
    
    if lv(j) >= 0
        title(sprintf('Lv = %6.4f', lv(j)));
    else
        title(sprintf('Episode #%d', j));
    end
    set(gca, 'FontSize', 6);
end
linkaxes(ax,'xy');

% Store the Lvs of Shinomoto
S.lv = lv;

ccount = 0;
l_text = {};
% Plot the ISI as a function of spike number
subplot(r,c,[hdr.lActualEpisodes+1 r*c]);
for j = 1:hdr.lActualEpisodes
    hold on;

%     % Subtract off the resting membrane potential
%     if ~isempty(S.pks{j})
%         S.pks{j} = S.pks{j}- mp.resting;
%     end

    if ~(length(S.locs{j}) < ap.io.minspikes) && (min(T(S.locs{j}))< ap.io.maxT)
        ccount = ccount + 1;
        ISI = diff(T(S.locs{j}));
        plot(ISI, 'Color',cmap(ccount,:));
        l_text{ccount} = sprintf('%d',j);
        S.isi{j} = ISI;
    else
        S.isi{j} = {};
    end 
end
hold off;
xlabel('Spike number');
ylabel('ISI (ms)');
legend(l_text, 'Location', 'EastOutside');
axis([0 max(xlim) 0 max(ylim)]);
set(gca, 'FontSize', 6);

% Keep some paramaters that might have changed
S.ap = ap;

%----------------- Individual Spike display --------------------------%

% Display all the spikes
w = ap.io.spikewindowtime*1e-3*sr;
t = (-w:w)/sr*1e3;

ftext = sprintf('%s - ISI Channel # %d',upper(fn), ap.io.ch_to_analyze);
[fcount, figs] = figure_set(fcount, figs, ftext);

for j = 1:hdr.lActualEpisodes
    ax(j) = subplot(r,c,j);
    set(gca, 'FontSize', 6);
    if ~isempty(length(S.locs{j}))
        hold on;
        sp = [];
        sp_count = 0;
        for s = 1:length(S.locs{j})
            if T(S.locs{j}(s)) < ap.io.maxT && S.locs{j}(s) > w
                sp_count = sp_count +1;
                sp(sp_count,:) = d((S.locs{j}(s)-w):(S.locs{j}(s)+w),ap.io.ch_to_analyze,j);
                % Display the first x spikes 
                if (sp_count <= ap.io.firstspikestodisp)
                    plot(t,sp(sp_count,:), 'Color', cmap(sp_count,:));
                else
                    plot(t,sp(sp_count,:), 'Color', [.7 .7 .7]);
                end
            end
        end
%         if sp_count>1
%             plot(t,mean(sp),'Color', [0 0 0]);
%         end
        hold off;
        spikes{j} = sp;
%         ylabel(hdr.recChUnits{ap.io.ch_to_analyze});
%         xlabel('Time (ms)');
        title(sprintf('Episode #%d', j));
        axis([t(1) t(end) ap.io.yaxis]);
    end
end
linkaxes(ax,'xy');

ccount = 0;
l_text = {};
% Plot the spike amplitudes
subplot(r,c,[hdr.lActualEpisodes+1 r*c]);
max_peaks = -1;
for j = 1:hdr.lActualEpisodes
    hold on;
    if ~isempty(S.pks{j})
        ccount = ccount + 1;
        plot(S.pks{j}, 'Color',cmap(ccount,:));
        l_text{ccount} = sprintf('%d',j);
        if length(S.pks{j}) > max_peaks
            max_peaks = length(S.pks{j});
        end
    end 
end
hold off;
xlabel('Spike number');
ylabel('Peak (mV)');
legend(l_text, 'Location', 'EastOutside');
if max_peaks > 0
    axis([0 max_peaks ylim]);
end
set(gca, 'FontSize', 6);

%-------------------------- SUMMARY NUMBERS -----------------------------%
if  prod(double(cellfun('isempty', S.pks))) == 1
    display('NO spikes detected for this cell...no summary stats')
    return;
end

R.spikes = spikes;
R.S = S;
R.mp = mp;

%[F, ~, ~] = collect_features(R);
[F, ~, ~] = collect_features(R);

feat{1} = F;
[all_features] = collapse_feature(feat, ap.io.features, ap.io.normalize);

% Make sure there is something in here to plot lest and error should occur
if min(size(all_features))
    ftext = sprintf('%s - FEATURES - Channel # %d',upper(fn), ap.io.ch_to_analyze);
    [fcount, figs] = figure_set(fcount, figs, ftext);
    plot_features(all_features,ap.io.firstspikestodisp, ap.io.features, ap.io.normalize);
end

% Do some stats
features_stats(all_features,ap);

%----------------------- Export the plots -------------------------------%

figure_batch_save(figs, eDir, dosave);
%---------------------   OTHER FUNCTIONS --------------------------------%

      
function [S] = find_spikes(d, T, ap)

[~, nepochs] = size(d);
S = [];

warning('off');

for j=1:nepochs
    ts = squeeze(d(:,j));
    [S.pks{j},S.locs{j}] = findpeaks(ts, 'MINPEAKHEIGHT', ap.io.minpeakheight);
    ind = find(T(S.locs{j}) > ap.io.pulsestart  & T(S.locs{j}) < (ap.io.pulsestart+ap.io.pulsedur));
    if ~isempty(ind)
        S.pks{j} = S.pks{j}(ind);
        S.locs{j} = S.locs{j}(ind);
    else
        S.pks{j} = [];
        S.locs{j} = [];
    end
end

warning('on');


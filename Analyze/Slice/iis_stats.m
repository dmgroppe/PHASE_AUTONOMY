function iis_stats(dap, all_pts, S)

global DATA_DIR;

% Get default analysis params
ap = sl_sync_params();

%% Load and set up data
ddir = fullfile(DATA_DIR, dap(1).Dir);
fname = char(dap(1).cond.fname);

if nargin < 2
    iis_fn = fullfile(dap(1).Dir, [fname '_iis.mat']);
    if exist(iis_fn)
        load(iis_fb);
    else
        error('No IIS matrix available');
    end
end

if nargin < 3
    ap.notch = 0;
    ap.notch_ch_list = [1 0];
    ap.srate = 0; % This forces the load to just the raw data
    S = load_dap(ddir, ap, fname);
end
[nchan npoints] = size(S.data);

% The time range of analysis
T = (0:(npoints-1))/S.srate;


% Find the appropriate channels
lfp_chan = find(strcmp('LFP', dap(1).chlabels) == 1,1);
light_chan = find(strcmp('LIGHT', dap(1).chlabels) == 1,1);
if isempty(lfp_chan) || isempty(light_chan)
    error('Light and/or LFP channel have not been specified in the EXCEL spreadsheet.');
end

% Collect all the light pulses
[P] = pulse_seq(S.data(light_chan,:));

if isempty(P)
    error('No light pusles detected.');
end

%% IIS maxima etc
iis_loc = squeeze(all_pts(1,:));
niis = length(iis_loc);
min_iis_loc = min(iis_loc);
max_iis_loc = max(iis_loc);

figure(10);clf;
for i=1:niis
    dstart = fix((iis_loc(i) - ap.ev_baseline)*S.srate);
    dend = fix((iis_loc(i)+ap.ev_dur)*S.srate)-1;
    iis_range(:,i) = [dstart dend];
    iis(:,i) = S.data(lfp_chan, dstart:dend);
    iis(:,i) = iis(:,i) - mean(iis(1:fix(ap.ev_baseline*S.srate/2),i));
    %[iis_max(i) iis_max_loc(i)] = max(abs(iis(:,i)));
    iis_max(i) = abs(max(abs(iis(:,i))) - min(abs(iis(:,i))));
end

% Plot the individual IIS
tp = (1:length(iis))/S.srate-ap.ev_baseline;
subplot(2,3,1);
for i=1:niis
  hold on
  plot(tp, smooth(iis(:,i),100), 'Color', [0 1 0]*i/niis);  
  hold off;
end
if ~isempty(ap.ev_yaxis)
    axis([tp(1) tp(end) ap.ev_yaxis]);
else
    axis([-ap.ev_baseline ap.ev_dur ylim]);
end
label_axes('Time(s)', 'mV');
axis square;
axes_text_style(gca, 8);

% Plot the IIS maxima
subplot(2,3,4);
plot(iis_range(1,:)/S.srate,iis_max, '.-b', 'MarkerSize', 8);
if ~isempty(ap.ev_yaxis)
    axis([min_iis_loc max_iis_loc 0 max(abs(ap.ev_yaxis))]);
end
label_axes('Time(s)', 'mV');
axis square;
axes_text_style(gca, 8);


%% Find the linght pulses in the range of the selected iis to analyze

lps_ind = find(P.range(:,1) >= min_iis_loc*S.srate & P.range(:,1) <= max_iis_loc*S.srate);
nlps = length(lps_ind);
for i=1:nlps
    dstart = P.range(lps_ind(i),1) - fix(ap.ev_baseline*S.srate); 
    dend = P.range(lps_ind(i),1) + fix(ap.ev_dur*S.srate)-1; 
    lp_range(:,i) = [dstart dend];
    lp(:,i) = S.data(lfp_chan, dstart:dend);
    lp(:,i) = lp(:,i) - mean(lp(1:fix(ap.ev_baseline*S.srate/2),i));
%     [lp_max(i) lp_max_loc(i)] = max(abs(lp(:,i)));
    lp_max(i)= abs(max(abs(lp(:,i))) - min(abs(lp(:,i))));
end

% LIGHT PULSE PLOT
subplot(2,3,2);
for i=1:nlps
  hold on
  plot(tp, smooth(lp(:,i),100), 'Color', [0 1.0 0]*i/nlps);  
  hold off;
end
label_axes('Time(s)', 'mV');
if ~isempty(ap.ev_yaxis)
    axis([tp(1) tp(end) ap.ev_yaxis]);
else
    axis([-ap.ev_baseline ap.ev_dur ylim]);
end
axis square;
axes_text_style(gca, 8);

% Plot the lp maxima
subplot(2,3,5);
plot(lp_range(1,:)/S.srate,lp_max, '.-b', 'MarkerSize', 8);
if ~isempty(ap.ev_yaxis)
    axis([min_iis_loc max_iis_loc 0 max(abs(ap.ev_yaxis))]);
end
label_axes('Time(s)', 'mV');
axis square;
axes_text_style(gca, 8);

corr_vals = [];
max_iis = -1;
for i=1:nlps-1
    iis_inrange{i} = find(iis_loc*S.srate >= P.range(lps_ind(i),1) & iis_loc*S.srate <= P.range(lps_ind(i+1),1));
    if ~isempty(iis_inrange)
        corr_vals = [corr_vals' [repmat(lp_max(i),1,length(iis_inrange{i}))' iis_max(iis_inrange{i})']']';
        if max_iis < numel(iis_inrange{i});
            % Just for plotting purposes
            max_iis = numel(iis_inrange{i});
        end
    end 
end

subplot(2,3,3);
plot(corr_vals(:,1), corr_vals(:,2), '.', 'LineStyle', 'none', 'MarkerSize', 8);
[r, p] = corr(corr_vals(:,1), corr_vals(:,2), 'type', 'Spearman');
title(sprintf('r = %4.2f, p = %6.4e', r, p));
if ~isempty(ap.ev_yaxis)
    axis([0 max(abs(ap.ev_yaxis)) 0 max(abs(ap.ev_yaxis))]);
end
axis square;
axes_text_style(gca);
label_axes('LP amplitude (mV)', 'IIS amplitude (mV)');
axes_text_style(gca, 8);


% if max_iis > 0
%     figure(11);clf;
%     for i=1:nlps-1
%         subplot(nlps-1,max_iis,(i-1)*max_iis+1);
%         plot(tp,lp(:,i));
%         axis([tp(1) tp(end) -5 1]);
%         set(gca, 'Visible', 'off');
%         for j=1:numel(iis_inrange{i})
%             subplot(nlps-1,max_iis,(i-1)*max_iis+1+j);
%             plot(tp,iis(:,iis_inrange{i}(j)));
%             axis([tp(1) tp(end) -5 1]);
%             set(gca, 'Visible', 'off');
%         end
%     end
% end












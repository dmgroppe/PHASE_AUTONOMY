function [R] = pageHinkley(sz_name, a_cfg, dosave)

global DATA_PATH;

if nargin < 3; dosave = 1; end;
if nargin < 2;
    a_cfg = cfg_default();
end;

pt_name = strtok(sz_name, '_');

if a_cfg.use_fband
    display('FBAND analysis selected...')
    suffix = '_F_FBAND';
    fpath = make_file_name(DATA_PATH, sz_name, 'Bipolar_FBAND', suffix);
    %file_name = sprintf('%s%s_%d_%dHz.mat', sz_name,suffix,a_cfg.fband(1), a_cfg.fband(2));
    F_data_file = fullfile(fpath, [sz_name suffix '.mat']);
    
else
    display('ADAPTIVE DERIV selected...')
    suffix = '_F\';
    fpath = make_file_name(DATA_PATH, sz_name, 'Adaptive deriv', suffix);
    %F_file = fullfile(fpath, ['All freqs - ' sz_name suffix(1:end-1) '.fig']);
    F_data_file = fullfile(fpath, [sz_name suffix(1:end-1) '.mat']);
end

% 
% if exist(F_file, 'file') && plot_fig
%     open(F_file);
%     % [rank, f_out] = Szprec_rank(F,cfg, a_cfg, pt_name);
%     % plot_f(f_out,matrix_bi,rank,Sf,cfg,pt_name, 5);
% end

if exist(F_data_file, 'file')
    display(sprintf('---------------Loading - %s', sz_name));
    load(F_data_file);
else
    display(F_data_file);
    display('File does not exist');
    return;
end

% Get the value of interest
if a_cfg.use_fband
    % Don't deal with multiple frequencies here
    S =F{1};
    % Some channels can have very high average levels - having said that
    % this analysis will likely be reserved for wavelet data

    S = S-repmat(mean(S),length(S),1);
    S = S-min(min(S));

else   
    % Normalize
    S = fNorm(F, pt_name, a_cfg);
end

[npoints, nchan] = size(S);
t = (0:(npoints-1))/Sf;

[bad_m_channels, bad_b_channels] = bad_channels_get(pt_name);


% Plot the precursor values
h1 = figure(1);clf;
set(h1, 'Name', sz_name);
subplot(2,1,1);
Szprec_tf(matrix_bi, Sf, cfg, pt_name);
drawnow;

%% Detect changes using Page-Hinkley Algorithm
tic
srate = Sf;

test_chan = 13;

% If seizure times are available remove the A values after the marked end;
if a_cfg.stats.use_szend
    if exist(make_data_path(pt_name, 'sz_times'), 'file');
        load(make_data_path(pt_name, 'sz_times'));
        ind = find(strcmp({sz_times.name}, sz_name) == 1, 1);
        if ~isempty(ind)
            end_point = fix(sz_times(ind).times(2,1)*srate);
        else
            end_point = npoints;
        end
    else
        end_point = npoints;
    end
else
    end_point = npoints;
end
a_ind = 1:end_point;

%% Do the PH detection
if 1
    s = 1;
    e = nchan;
    U = cell(1,e);
    hp = U;
    A = U;
    surr_A = U;
    parfor i=s:e
        if isempty(find(i == bad_b_channels,1))
            display(sprintf('Working on channel #%d', i));
            [hp{i}, A{i}, U{i}, pval{i}, surr_A{i}] = change_detect(S(a_ind,i), a_cfg.stats.bias, srate*a_cfg.stats.sm_window,...
                a_cfg.stats.nsurr, a_cfg.stats.lbp, 0);
        else
            hp{i} = [];
            A{i} = [];
            pval{i} = [];
            surr_A{i} = [];
            U{i} = [];
            surr_A{i} = [];
        end
    end
else
    
    s = test_chan;
    e = test_chan;
    
    for i=s:e
        display(sprintf('Working on channel #%d', i));
        [hp{i}, A{i}, U{i}, pval{i}, surr_A{i}] = change_detect(S(a_ind,i), a_cfg.stats.bias, srate*a_cfg.stats.sm_window,...
            a_cfg.stats.nsurr, a_cfg.stats.lbp, 1);
    end
end

dU = zeros(length(S),nchan);
for j=1:numel(U)
    if ~isempty(U{j})
        %dU(1:length(U{j}),j) = detrend(U{j}, 'linear');
        dU(1:length(U{j}),j) = U{j};
    end
end
toc

% Compute new p values by combining surrogate values from all channels.

all_surr_A = [];
if a_cfg.stats.nsurr 
    if a_cfg.stats.global_p
        all_surr_A = [];
        for i=1:numel(surr_A)
            all_surr_A = [all_surr_A;surr_A{i}];
        end

        for i=s:e
            for j=1:numel(A{i})
                pval{i}(j) = sum(A{i}(j) < all_surr_A)/numel(all_surr_A);
            end
        end
    end
    display(sprintf('Number of surrogate values = %d', length(all_surr_A)));
end



%% Plot the Page-Hinkley values
cm = cbrewer('div', 'RdYlBu', 64);
colormap(flipud(cm));

subplot(2,1,2);
imagesc(t, 1:nchan, dU');

if a_cfg.stats.uCaxis
    caxis(a_cfg.stats.uCaxis);
end

axis([t(1) t(end) -1 nchan+2 0 1]);
set(gca, 'FontSize' , 7);
set(gca, 'TickDir', 'out');
view(0,90);
xlabel('Time (s)');
ylabel('Channel number');
title('Detrended Page-Hinkley');


%% Get earliest significant changes
loc = ones(1,nchan)*npoints;
loc_pval = ones(1,nchan);
loc_A = zeros(1,nchan);
for i=s:e
    if a_cfg.stats.use_max 
        if a_cfg.stats.nsurr
            pind = find(pval{i} < a_cfg.stats.alpha);
            if ~isempty(pind)
                [loc_A(i) m_ind] = max(A{i});
                if hp{i}(m_ind,1)/srate >= a_cfg.stats.mint
                    loc(i) = hp{i}(m_ind,1);
                end
            end
        else
            [loc_A(i) m_ind] = max(A{i});
            if hp{i}(m_ind,1)/srate >= a_cfg.stats.mint
                loc(i) = hp{i}(m_ind,1);
            end
        end
    elseif ~isempty(pval{i})
%         if i ==13;
%             a = 1;
%         end
        pind = find(pval{i} < a_cfg.stats.alpha);
        if ~isempty(pind)
            p_ok = find(hp{i}(pind,1)/srate >= a_cfg.stats.mint);
            if ~isempty(p_ok)
                loc(i) = hp{i}(pind(p_ok(1)),1);
                loc_pval(i) = pval{i}(pind(p_ok(1)));
                loc_A(i) = A{i}(pind(p_ok(1)));
            end
        end
    end
end


%% Sort the changes and plot the results

% % Check to see if there is a remmapping of electrodes to be done.
% if a_cfg.stats.remap_electrodes
%     eh = electrode_remap_get(sz_name);
%     if ~isempty(eh)
%         % Remap the electrodes
%         display('--- An electrode remapping was performed.')
%         loc = loc(eh);
%     end
% end

[loc_sorted, ind] = sort(loc,'ascend');
[A_sorted, ind_A] = sort(loc_A, 'descend');

% If no onset set to NaN for further identification that no onset was
% detected
loc(find(loc == npoints)) = NaN;

% Flag - for making figures without the red dots
if a_cfg.stats.plot_onsets
    for i=s:e
        if ~isnan(loc(i))
            subplot(2,1,1); hold on;
            plot([loc(i) loc(i)]/srate, [i i], 'r.', 'LineStyle', 'none', 'MarkerSize', 10);
            hold off;

            subplot(2,1,2); hold on;
            plot([loc(i) loc(i)]/srate, [i i], 'r.', 'LineStyle', 'none', 'MarkerSize', 12);
            hold off;
        end
    end
end


% Relabel the axes since the above code for some reason erases the right
% axis labels

subplot(2,1,1);
ax_p1 = re_label_yaxis(pt_name, cfg, t, nchan);
subplot(2,1,2);
ax_p2 = re_label_yaxis(pt_name, cfg, t, nchan);
linkaxes([ax_p1 ax_p2], 'xy');

[ch_labels, ~] = get_channels_with_text(pt_name, [], 'bipolar');
ch_list = ch_labels(ind);

%% Summarize the data using various sorted and unsorted channel location lists

h2 = figure(2); clf;
set(h2, 'Name', sprintf('Szprec_page_hinkley summary: %s', sz_name));
subplot(2,2,1);
barh(1:length(A_sorted), A_sorted);
axis([xlim 1 length(A_sorted)+1]);
set(gca, 'YDir', 'reverse', 'TickDir', 'out');
set(gca, 'YTick', 1:numel(A_sorted));
set(gca, 'YTickLabel', ch_labels(ind_A), 'FontSize', 4,'FontName','Small fonts');
xlabel('Amplitude of change (units)', 'FontSize', 6);
title('Amplitude of changes');


% PLot the correlation of times and amplitudes
subplot(2,2,2);
corr_loc = loc_sorted;
excl = find(loc_sorted == npoints);
corr_loc(excl) = [];
A_ind = ind;
A_ind(excl) = [];

plot(t(corr_loc), loc_A(A_ind), '.', 'LineStyle', 'none', 'MarkerSize', 10);
xlabel('Time of change(s)');
ylabel('Amplitude of change');

if ~isempty(corr_loc) && ~isempty(A_ind)
    [rho, p] = corr(t(corr_loc)', loc_A(A_ind)', 'type', 'Spearman');
    title(sprintf('r = %6.2f, p = %6.4f', rho, p));
end

% Plot without sorting the timing of changes
subplot(2,2,4);

p_loc = loc/srate-nanmedian(loc/srate);
ind = find(isnan(p_loc) == 0);
p_loc = (p_loc-nanmedian(p_loc))/iqr(p_loc(ind));

barh(1:length(loc), p_loc);
axis([xlim 0 length(loc)+1]);
set(gca, 'YDir', 'reverse', 'TickDir', 'out');
set(gca, 'YTick', 1:numel(loc));
set(gca, 'YTickLabel', ch_labels, 'FontSize', 4,'FontName','Small fonts');
xlabel('Time - mean time across channels', 'FontSize', 5);
title('Unranked time of change - mean across channels', 'FontSize', 6);

% PLot the times of detected changes
subplot(2,2,3);
[tp, tp_ind] =  sort(p_loc);

barh(1:length(loc_sorted), tp);
axis([xlim 0 length(loc_sorted)+1]);
set(gca, 'YDir', 'reverse', 'TickDir', 'out');
set(gca, 'YTick', 1:numel(loc_sorted));
set(gca, 'YTickLabel', ch_labels(tp_ind), 'FontSize', 4,'FontName','Small fonts');
xlabel('Time of earliest stat sig change (s)', 'FontSize', 6);
title('Timing of changes');

% save all the stuff
if a_cfg.stats.use_max
    suf = '_max';
else
    suf = '_early';
end

fdir = fullfile(fpath,['Page-Hinkley' suf]);
if ~exist(fdir, 'dir')
    mkdir(fdir);
end

fname = fullfile(fdir, [sz_name '-PH']);
R = struct_from_list('hp', hp, 'A', A, 'U', U, 'pval', pval,...
    'loc', loc, 'loc_pval', loc_pval, 'loc_A', loc_A, 'a_cfg', a_cfg,...
    'all_surr_A', all_surr_A, 'srate', srate);

if dosave
    saveas(h1, fname);
    save(fname, 'R');
    save_figure(h1, fdir, [sz_name '-PH'], false);

    fname = fullfile(fdir, [sz_name '-PH Summary']);
    saveas(h2, fname);
    save_figure(h2, fdir, [sz_name '-PH Summary'], false);
end

%% Support functions
function [fname] = make_file_name(DATA_PATH, sz_name, folder, suffix)
pt_name = strtok(sz_name, '_');
fname = fullfile(DATA_PATH, 'Szprec',  pt_name, 'Processed', folder,...
        [sz_name suffix]);
        
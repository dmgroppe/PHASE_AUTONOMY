function [ms, ms_surr] = sync_freq_tsbs(EEG, ch_pair, ap, dosave)
% Computes the BS stats for the sync_freq dependance for a single pair
% of contacts
%
% ANALYSIS Params that need to be set externally
%   ap.condlist = {'aloud', 'quiet', 'rest_eo'};
%   ap.atype = 'pc';
%   ap.ptname = 'vant';
%   ap.usewt = 1;
%   ap.surr = 0;
%   ap.freqs = 2:2:50;
%   ap.yaxis = [0 0.7];
%   ap.nsurr = 200; % Number of surrogates to run
%   ap.surr = 1;

export_path = [get_export_path_SMA() 'TSBS\'];

if nargin <2; dosave = 0; end;

% Compute actual freq dependence
ap.surr = 0;
condlist = ap.condlist;

% Print the starting time
fprintf('Starting: %s\n',datestr(now));
fprintf(' Ch pair = %d-%d\n', ch_pair(1), ch_pair(2));

display('Computing freq-dependant syncs.');
parfor i=1:numel(ap.condlist)
    [~, ~, ~, ms(:,i)] = sync_freq_dependence(EEG, condlist{i}, ch_pair, ap);
end

% Collect all the pairs
[P] = pairs_all_types(ap.ptname);
all_pairs = P.notlocal_notinside;
npairs = length(P.notlocal_notinside);
apairs = squeeze(reshape(all_pairs(:,fix(rand(ap.nsurr,1)*npairs) + 1), [2,1,ap.nsurr]));

switch ap.sync_freq_surr
    case 'time_shift'
        % Reset to do the time-shift surrogates
        ap.surr = 1;
        surr_type_name = 'TS';
    case 'rand_pairs'
        surr_type_name = 'RP';
end

fprintf('\n');
sync_freq_surr = ap.sync_freq_surr;

ms_surr = zeros(length(ap.freqs), ap.nsurr, numel(ap.condlist));

for i=1:numel(ap.condlist)
    % Loop over all the surrogates
    fprintf('Computing surrogates - working on condition %d of %d\n', i, numel(ap.condlist));
    cond = ap.condlist{i};
    parfor j=1:ap.nsurr
        % ms_surr contains the individual surrogate values
        switch sync_freq_surr
            case 'time_shift'
                [~, ~, ~, ms_surr(:,j,i)] = sync_freq_dependence(EEG, cond, ch_pair, ap);
            case 'rand_pairs'
                [~, ~, ~, ms_surr(:,j,i)] = sync_freq_dependence(EEG, cond, apairs(:,j), ap);
        end
    end
end

% Get probabilities and FDR correct
[sig_inc, sig_dec] = get_freqdep_sig(ms_surr, ms, ap.alpha);

% Plot the results
h = figure(1);
clf('reset');
set(h, 'Name', 'Sync freq dependance TS BS');

color_list = {'b', 'g', 'r', 'm'};

if numel(ap.condlist) == 1
    subplot(2,1,1);
end

for i=1:numel(ap.condlist)
    
    if strcmp(ap.pl.axis, 'linear')
        plot(ap.freqs, ms(:,i), color_list{i});
    else
        semilogx(ap.freqs, ms(:,i), color_list{i});
    end
    
    hold on;
    for j=1:length(ms)
        if sig_inc(j,i)
            if strcmp(ap.pl.axis, 'linear')
                plot(ap.freqs(j), ms(j,i), [color_list{i} '.'], 'MarkerSize', 15);
            else
                semilogx(ap.freqs(j), ms(j,i), [color_list{i} '.'], 'MarkerSize', 15);
            end
        end
    end
end
hold off;

if ~isempty(ap.yaxis)
    axis([0 ap.freqs(end) ap.yaxis]);
end
hold off;
xlabel('Freq (Hz)');
ylabel(upper(ap.atype));
set(gca, 'TickDir', 'out');

if ~isempty(ap.yaxis)
    yaxis = ap.yaxis;
else
    yaxis = [0 max(max(ms))];
end

% Plot the frequency ranges
plot_ranges(ap.extrema_range, yaxis, 'vert');

% if only one condition hen plot the sig values as a separate plot so I can
% plot them
if numel(ap.condlist) == 1
    subplot(2,1,2);
    [~,sig] = sig_to_ranges(sig_inc, ap.freqs, ap.minr);
    if strcmp(ap.pl.axis, 'linear')
        plot(ap.freqs, sig);
    else
        semilogx(ap.freqs, sig);
    end
    axis([0 ap.freqs(end) 0 1]);
end

%cl = mean()squeeze(sqrt(ss/ap.nsurr)*1.96/sqrt(nsurrch));
%boundedline(ap.freqs, ms, cl, color_list{i}, 'transparency', 0.5);


% Save the results
if dosave
    fname = sprintf('Sync_freq_dep %s %sBS %s %s CH %d-%d', upper(ap.atype),...
        surr_type_name, ap.ptname, ap.atype, ch_pair(1), ch_pair(2));
    fprintf('Saving to: %s\n', fname);
    save_figure(h,export_path, fname);
    % Save the actualy ms and sinificance values for further plotting etc
    save([export_path fname '.mat'], 'ms', 'ms_surr', 'sig_inc', 'sig_dec', 'ap');
end




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

% Reset to do the time-shift surrogates
ap.surr = 1;

fprintf('\n');
for i=1:numel(ap.condlist)
    % Loop over all the surrogates
    fprintf('Computing surrogates - working on condition %d of %d\n', i, numel(ap.condlist));
    cond = ap.condlist{i};
    parfor j=1:ap.nsurr
        % ms_surr contains the individual surrogate values
        [~, ~, ~, ms_surr(:,j,i)] = sync_freq_dependence(EEG, cond, ch_pair, ap);
    end
end

% Get probabilities and FDR correct
[sig_inc, sig_dec] = get_freqdep_sig(ms_surr, ms, ap.alpha);

% Plot the results
h = figure(1);
clf('reset');
set(h, 'Name', 'Sync freq dependance TS BS');

color_list = {'b', 'r', 'g', 'm'};
for i=1:numel(ap.condlist)
    
    plot(ap.freqs, ms(:,i), color_list{i});
    hold on;
    for j=1:length(ms)
        if sig_inc(j,i)
            plot(ap.freqs(j), ms(j,i), [color_list{i} '.'], 'MarkerSize', 15);
        end
    end
end

hold off;

%cl = mean()squeeze(sqrt(ss/ap.nsurr)*1.96/sqrt(nsurrch));
%boundedline(ap.freqs, ms, cl, color_list{i}, 'transparency', 0.5);

if ~isempty(ap.yaxis)
    axis([0 ap.freqs(end) ap.yaxis]);
end
hold off;
xlabel('Freq (Hz)');
ylabel(upper(ap.atype));

% Save the results
if dosave
    fname = sprintf('Sync_freq_dep %s TSBS %s %s CH %d-%d', upper(ap.atype),...
        ap.ptname, ap.atype, ch_pair(1), ch_pair(2));
    fprintf('Saving to: %s\n', fname);
    save_figure(h,get_export_path_SMA(), fname);
    % Save the actualy ms and sinificance values for further plotting etc
    save([get_export_path_SMA() fname '.mat'], 'ms', 'sig_inc', 'sig_dec', 'ap');
end




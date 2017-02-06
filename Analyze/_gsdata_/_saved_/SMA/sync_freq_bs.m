function [mean_sync std_sync ap] = sync_freq_bs(EEG, dosave)
% Computes the sync-freq dependance for random pairs (number specified),
% from a specific set of channel pairs

if nargin <2; dosave = 0; end;

% Get the analysis params
ap = sync_params();
ap.condlist = {'aloud', 'quiet', 'rest_eo'};
ap.atype = 'pc';
ap.ptname = 'vant';
ap.usewt = 1;
ap.surr = 0;
ap.freqs = 50:10:500;
ap.yaxis = [0 0.2];

% Sync freq depedence surrogate analysis
ap.nsurrch = 12;  % Number of surrogate channels
ap.nsurr = 100; % Number of surrogates to run

% for the moment we will include all non-local pairs outside of the DSN
[P] = pairs_all_types(ap.ptname);
all_pairs = P.notlocal_notinside;
npairs = length(P.notlocal_notinside);

nsurrch = ap.nsurrch;

fprintf('\n');
fprintf('\nStarting: %s\n',datestr(now));
for i=1:numel(ap.condlist)
    % Loop over all the surrogates
    %tic
    fprintf('Working on condition %d of %d\n', i, numel(ap.condlist));
    apairs = reshape(all_pairs(:,fix(rand(ap.nsurr,nsurrch)*npairs) + 1), [2,nsurrch,ap.nsurr]);
    cond = ap.condlist{i};
    parfor j=1:ap.nsurr
        [mean_sync(:,j,i), std_sync(:,j,i), ~] = sync_freq_dependence(EEG, cond, apairs(:,:,j), ap);
    end
    %toc
end

h = figure(1);
clf('reset');
set(h, 'Name', 'Sync freq dependance BS');

color_list = {'b', 'r', 'g', 'm'};
for i=1:numel(ap.condlist)
    ms = squeeze(mean(mean_sync(:,:,i), 2));
    ss = 0;
    % Average the sum of the squares of the stds
    for j=1:ap.nsurr
        ss = ss + std_sync(:,j,i).^2;
    end
    cl = squeeze(sqrt(ss/ap.nsurr)*1.96/sqrt(nsurrch));
    boundedline(ap.freqs, ms, cl, color_list{i}, 'transparency', 0.5);
    
    if i == 1
        hold on;
    end
end
if ~isempty(ap.yaxis)
    axis([ap.freqs(1) ap.freqs(end) ap.yaxis]);
end
hold off;
xlabel('Freq (Hz)');
ylabel(upper(ap.atype));

if dosave
    fname = sprintf('Sync_freq_dep BS %s %s', ap.ptname, ap.atype);
    save_figure(h,get_export_path_SMA(), fname);
end




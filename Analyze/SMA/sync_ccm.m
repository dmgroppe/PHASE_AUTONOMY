function [rf rb p] = sync_ccm(EEG, ptname, pairs, cond, dosave)

if nargin < 5; dosave = false; end;

% Perform empiricle mode decomposition

ap = sync_params();

if isrow(pairs)
    pairs = pairs';
end

npairs = size(pairs,2);
subr = data_retrieve(EEG, cond, ap.length, ptname);
d = window_FIR(ap.ccm.frange(1), ap.ccm.frange(2), EEG.srate);

for i=1:npairs
    display(sprintf('Working on pair %d of %d', i, npairs));
    ts = subr(pairs(:,i),:);
    X.data = filtfilt(d.Numerator, 1, ts(1,:));
    Y.data = filtfilt(d.Numerator, 1, ts(2,:));
    X.FText = sprintf('CH%d', pairs(1,i));
    Y.FText = sprintf('CH%d', pairs(2,i));

    [rf{i} rb{i} p{i}] = ccm(X, Y, 'dim',ap.ccm.dim, 'tau', ap.ccm.tau, 'alpha', ap.ccm.alpha, 'nsurr',...
        ap.ccm.nsurr, 'Tps', ap.ccm.Tps, 'Nseg', ap.ccm.Nseg, 'dosave', dosave, 'Lsteps', ap.ccm.Lsteps);
end

fname = sprintf('SYNC_CCM - %s %s %4.f-%4.0f.mat', upper(ptname), upper(cond), ap.ccm.frange(1), ap.ccm.frange(2));

save([get_export_path_SMA() fname], 'rf', 'rb', 'p', 'ap', 'ptname', 'pairs', 'cond');



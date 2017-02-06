function [R] = phProcessHilbert(sz_list, dosave)

if nargin < 1
    sz_list = sz_list_load();
    if isempty(sz_list)
        return;
    end
else
    if numel(sz_list) > 1
        sz_list{1} = sz_list;
    end
    
end
if nargin <2; dosave = 1; end;

%% Default Values specific to the Hilbert analysis
cfg = cfg_default();
cfg.stats.prec_weight = 'mean'; % Works best with taking the mean
cfg.stats.freqs_to_use = 1:6;
cfg.useFilterBank = true;           % Use band pass filtering rather than WAVELET
cfg.freqs = [6 10 20 30 60 100];
cfg.fband = [[4 8];[8 12];[15 20];[20 30];[30 60];[60 100]]';
cfg.use_fband = false; % This is not used anymore but needs to set to false
cfg.stats.sm_window = 0.5; % smoothing window in seconds
cfg.f_caxis = [];

%% Run the analysis

for i=1:numel(numel(sz_list))
    pt_name = strtok(sz_list{i}(1), '_');
    %cfgs(i) = get_cfg(pt_name{1}, cfg);
    cfgs(i) = cfg; % Just use the defaults
end

for i=1:numel(numel(sz_list))
    for j=1:numel(sz_list{i})
        R{i}{j} = pageHinkley(sz_list{i}{j}, cfgs(i), dosave);
    end
end


%% Set the specific values for each subject if necessary
function [cfg] = get_cfg(sdir, cfg)

switch sdir
    case 'NA'
%         cfg.stats.bias = 0.01;
%         cfg.stats.alpha = 0.01;
%         cfg.stats.lbp = 5;
%         cfg.stats.sm_window = 1; % smoothing window in seconds
        % For hilbert analysis
        cfg.stats.bias = 0.01;
        cfg.stats.alpha = 0.01;
        cfg.stats.lbp = 5;
        cfg.stats.sm_window = 0.5; % smoothing window in seconds

   case 'CT'
        cfg.stats.bias = 0.01;
        cfg.stats.alpha = 0.005;
        cfg.stats.lbp = 5;
        cfg.stats.sm_window = 1; % smoothing window in seconds
   case 'SP'
        cfg.stats.bias = 0.01;
        cfg.stats.alpha = 0.01;
        cfg.stats.lbp = 5;
        cfg.stats.sm_window = 1; % smoothing window in seconds
   case 'IM'
        cfg.stats.bias = 0.01;
        cfg.stats.alpha = 0.01;
        cfg.stats.lbp = 5;
        cfg.stats.sm_window = 1; % smoothing window in seconds
   case 'MSt'
        cfg.stats.bias = 0.01;
        cfg.stats.alpha = 0.005;
        cfg.stats.lbp = 5;
        cfg.stats.sm_window = 1; % smoothing window in seconds
   case 'ME'
        cfg.stats.bias = 0.01;
        cfg.stats.alpha = 0.01;
        cfg.stats.lbp = 5;
        cfg.stats.sm_window = 1; % smoothing window in seconds
   case 'AV'
        cfg.stats.bias = 0.01;
        cfg.stats.alpha = 0.01;
        cfg.stats.lbp = 5;
        cfg.stats.sm_window = 1; % smoothing window in seconds
        cfg.stats.use_szend = false;
   case 'SV'
        cfg.stats.bias = 0.01;
        cfg.stats.alpha = 0.0001;
        cfg.stats.lbp = 5;
        cfg.stats.sm_window = 0.25; % smoothing window in seconds
   case 'BH'
        cfg.stats.alpha = 0.01;
        cfg.stats.bias = 0.01;
        cfg.stats.lbp = 5;
        cfg.stats.sm_window = 1; % smoothing window in seconds
   case 'CJ'
        cfg.stats.bias = 0.01;
        cfg.stats.alpha = 0.01;
        cfg.stats.lbp = 5;
        cfg.stats.sm_window = 1; % smoothing window in seconds
   case 'TF'
        cfg.stats.alpha = 0.005;
        cfg.stats.lbp = 5;
        cfg.stats.bias = 0.01;
        cfg.stats.sm_window = 1; % smoothing window in seconds
   case 'CO'
        cfg.stats.mint = 10; % Stats are done only after this time (s)
        cfg.stats.bias = 0.02;
        cfg.stats.lbp = 10;
        cfg.stats.sm_window = 1; % smoothing window in seconds
        cfg.stats.global_p = true;
   case 'LD'
        cfg.stats.mint = 10; % Stats are done only after this time (s)
        cfg.stats.bias = 0.01;
        cfg.stats.lbp = 10;
        cfg.stats.sm_window = 1; % smoothing window in seconds
        cfg.stats.global_p = true;
   
 
end
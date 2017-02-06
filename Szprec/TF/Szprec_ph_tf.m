function S = Szprec_ph_tf(sz_list, pt_name, a_cfg)

% This function computes the power and precursor values in a window around
% where seizures onsets were detected.  These values then are summarized
% for each channel across all seizures, and then ultimately lumped to
% together to assess the relationship between power changes and precursor
% values.  The hypothesis that precursor values are not just detections of
% power.

% Get the list of seizures to be analyzed
if isempty(sz_list)
    szs = fullfile(DATA_DIR, 'Szprec', 'sz_list.mat');
    if ~exist(szs, 'file')
        display(szs);
        display('Sz list file not found');
        return;
    end
    load (szs);
end

if iscell(sz_list{1})
    % this is multiple patient
    % Find the list of interest
    n_length = length(pt_name);
    for i=1:numel(sz_list)
        if strcmpi(pt_name, sz_list{i}{1}(1:n_length))
            proc_list = sz_list{i};
            break;
        end
    end
else
    proc_list = sz_list;
end
    
% Get the spectra for all onsets for each channel and seizure the patient
% had
tic
if a_cfg.stats.tf_parallelize
    parfor i=1:numel(proc_list)
        [PH, F, D] = Szprec_load_all(proc_list{i});
        if ~isempty(PH) && ~isempty(F) && ~isempty(D)
            S{i} = do_tf(PH, F, D, a_cfg);
        end
    end
else
    for i=1:numel(proc_list)
        [PH, F, D] = Szprec_load_all(proc_list{i});
        if ~isempty(PH) && ~isempty(F) && ~isempty(D)
            S{i} = do_tf(PH, F, D, a_cfg);
        end
    end
end
toc

% Save the analysis:
display('Saving results...');
switch a_cfg.stats.ph_tf_onset_seg
    case 'pre'
        subdir = 'Ph_stats_pre';
    case 'start'
        subdir = 'Ph_stats_start';
end

pdir = fullfile(make_data_path(pt_name,  'processed_dir'), subdir);
fname = fullfile(pdir, [pt_name '_PH_TF.mat']);
save(fname, 'S', 'a_cfg', 'proc_list', '-v7.3');

% --------------------------------------Support functions
function [spec] = do_tf(PH, F, D, cfg)

spect_struct = struct('seg', [], 'p_spec', [], 'f_spec', [], 'p', [], 'f', []);
for i=1:length(PH.loc)
    if ~isnan(PH.loc(i))
        a_ind = find(PH.loc(i) == PH.hp{i}(:,1), 1);
        if ~isempty(a_ind)
            d.y = D.matrix_bi(:,i);
            d.srate = D.Sf;
            f = F(:,:,i);
            spec(i) = tf(f, d, cfg, PH.hp{i}(a_ind,:));
        end
    else
        spec(i) = spect_struct;
    end
end

function [R] = tf(F, d, cfg, loc)

d_ind{2} = loc(1):loc(2); % Seizure onset to peak of FV increase


switch cfg.stats.ph_tf_onset_seg
    case 'pre'
        % Just before seizure start
        d_ind{1} = loc(1)-length(d_ind{2}):loc(1);
        d_ind{1}(find(d_ind{1} <=0)) = [];
    case 'start'
        % From beginning of file - so further away than above
        d_ind{1} = d_ind{2}-loc(1)+1;
        d_ind{1} = d_ind{1}(find(d_ind{1} < d_ind{2}(1)));
end


for i=1:length(loc)
    seg{i} = d.y(d_ind{i});
    wt = twt(remove_nans(seg{i})', d.srate,linear_scale(cfg.stats.ph_tf_freqs, d.srate),5);
    p{i} = abs(wt); 
    p_spec(:,i) = mean(p{i},2);
    
    f{i} = squeeze(F(:,d_ind{i}));
    f_spec(:,i) = mean(f{i},2);
end

R = struct_from_list('seg', seg, 'p_spec', p_spec, 'f_spec', f_spec, 'p', p, 'f', f);
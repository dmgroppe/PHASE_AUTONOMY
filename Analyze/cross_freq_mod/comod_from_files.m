function [param_list, frq, mod_phase, mod_str, mod_str_comb, mod_phase_as, mod_str_as] = comod_from_files(sf, exp_info, plot)

if (nargin < 3); plot = []; end;

nsubjects = sf{1}.nsubjects;

spectra = [];
mod_phase = cell(nsubjects,2);
mod_str = cell(nsubjects,2);
mod_str_as = cell(nsubjects,2);     % MS across subjects within conditions
mod_str_comb = cell(nsubjects, 2);  % MS a la Axmacher (within subject)
sub_spectra = cell(2,1);

for i=1:nsubjects
%% Load and compute the mod_phase, and str for condition 1
    load(sf{1}.files{i});
    param_list{i,1} = params;
    bl_samples = time_to_samples(param_list{1,1}.ana.baseline, param_list{1,1}.data.srate);

    % Remove the baseline from the calculations
    sub_spectra{1} = spectra(:,(bl_samples+1):end,:);

    display(sprintf('Computing mod-phase, mod-strength for subject %d, condition 1.', i));
    [mod_phase{i,1} mod_str{i,1}] = cross_freq_mod(sub_spectra{1});
    
    % Plot the results
    if (~isempty(plot))
        h = figure(1);
        title = sprintf('%s %s %s COMOD', exp_info.anat_loc, exp_info.test, exp_info.cond1);
        set(h, 'Name', title);   
        plot_cfmodulation(mod_phase{i,1}, mod_str{i,1}, params, frq);
    end
    
%% Load and compute the mod-phase, and str for condition 2
    load(sf{2}.files{i});
    param_list{i,2} = params;
    
    % Remove the baseline from the calculations
    sub_spectra{2} = spectra(:,(bl_samples+1):end,:);

    display(sprintf('Computing mod-phase, mod-strength for subject %d, condition 2.', i));
    [mod_phase{i,2} mod_str{i,2}] = cross_freq_mod(sub_spectra{2});
    
     % Plot the results
    if (~isempty(plot))
        h = figure(2);
        title = sprintf('%s %s %s COMOD', exp_info.anat_loc, exp_info.test, exp_info.cond2);
        set(h, 'Name', title);   
        plot_cfmodulation(mod_phase{i,2}, mod_str{i,2}, params, frq);
    end
    
%% Compute the MP across conditions within subject then
%   recompute the MS
    mp = mod_phase{i,1} + mod_phase{i,2};
    
    display(sprintf('Recomputing mod-strengths for subject %d.', i));

    ms = zeros(length(frq), length(frq));
    for j=1:size(sub_spectra{1},3)
        ms = ms + mod_strength(sub_spectra{1}(:,:,j),mp);
    end
    mod_str_comb{i,1} = ms/size(sub_spectra{1},3);
    
    ms(:,:) = 0;
    for j=1:size(sub_spectra{2},3)
        ms = ms + mod_strength(sub_spectra{2}(:,:,j),mp);
    end
    mod_str_comb{i,2} = ms/size(sub_spectra{2},3);
%% Plot again
    if (~isempty(plot))
        h = figure(3);
        title = sprintf('%s %s %s COMOD', exp_info.anat_loc, exp_info.test, exp_info.cond1);
        set(h, 'Name', title);   
        plot_cfmodulation(mp, mod_str_comb{i,1}, params, frq);
    
        h = figure(4);
        title = sprintf('%s %s %s COMOD', exp_info.anat_loc, exp_info.test, exp_info.cond2);
        set(h, 'Name', title);   
        plot_cfmodulation(mp, mod_str_comb{i,2}, params, frq);
    end 
end

% Compute MS, with MP within conditions
[mod_phase_as, mod_str_as] = ms_mpas(sf, mod_phase);

save(exp_info.precompFile,'mod_phase', 'mod_str', 'mod_str_comb', 'mod_phase_as', 'mod_str_as', 'exp_info', 'param_list', 'frq');


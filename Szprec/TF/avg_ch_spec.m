function [R] = avg_ch_spec(S, cfg)
% Average the spectra across all seizures for each channel

if nargin < 4; doplot = 0; end;

ind = find(~cellfun('isempty', S) == 1, 1);
nsz = numel(S);
nchan = numel(S{ind});


for i=1:nchan
    c = 0;
    p_specs = [];
    f_specs = [];
    for j=1:nsz
        if ~isempty(S{j})
            if i <= numel(S{j})
                if ~isempty(S{j}(i).p_spec)
                    c = c+1;
                    p_specs(:,:,c) = S{j}(i).p_spec;
                    f_specs(:,:,c) = S{j}(i).f_spec;
                end
            end
        end
    end
    P{i} = p_specs;
    F{i} = f_specs;
    
    P_mean{i} = mean(p_specs,3);
    P_std{i} = std(p_specs,[], 3);
    
    F_mean{i} = mean(f_specs,3);
    F_std{i} = std(f_specs,[], 3);
end

% Get significant increases in power across seizures for each of the
% channels for each frequency
for i=1:nchan
    if ~isempty(P{i})
        P_sig{i} = fdr_vector(r_sum(P{i}), cfg.stats.ph_tf_alpha);
    else
        P_sig{i} = [];
    end
    
    if ~isempty(F{i})
        F_sig{i} = fdr_vector(r_sum(F{i}), cfg.stats.ph_tf_alpha);
    else
        F_sig{i} = [];
    end
end


R = struct_from_list('P_mean', P_mean, 'F_mean', F_mean, 'P', P, 'F', F, 'F_sig',...
    F_sig, 'P_sig', P_sig, 'nchan', nchan, 'nsz', nsz);

% Plot the results
if doplot
    h = plot_avg_ch_spec(R,cfg, ch);
end

function [p] = r_sum(m)

[nfreq,~,~] = size(m);

for i=1:nfreq
    [p(i), ~] = ranksum(squeeze(m(i,1,:)),squeeze(m(i,2,:)));
end
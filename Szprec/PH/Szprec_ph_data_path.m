function [dp] = Szprec_ph_data_path(cfg, sz_name, atype)

global DATA_PATH;

pt_name = strtok(sz_name, '_');

if cfg.use_fband 
    dp = fullfile(DATA_PATH, 'Szprec', pt_name, '\Processed\Bipolar_FBAND',...
            [sz_name '_F_FBAND'], ['Page-Hinkley_' atype]);
else
    dp = fullfile(DATA_PATH, 'Szprec', pt_name, '\Processed\Adaptive deriv',...
            [sz_name '_F'], ['Page-Hinkley_' atype]);
end
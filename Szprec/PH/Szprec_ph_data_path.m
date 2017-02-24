function [dp] = Szprec_ph_data_path(cfg, sz_name, atype)

% global DATA_PATH; DG change
global DATA_DIR

pt_name = strtok(sz_name, '_');
dot_id=find(sz_name=='.');
if ~isempty(dot_id),
   sz_name=sz_name(1:dot_id-1); 
end

% if cfg.use_fband 
%     dp = fullfile(DATA_DIR, 'Szprec', pt_name,'Processed','Bipolar_FBAND',...
%             [sz_name '_F_FBAND'], ['Page-Hinkley_' atype]);
% else
%     dp = fullfile(DATA_DIR, 'Szprec', pt_name, 'Processed','Adaptive deriv',...
%             [sz_name '_F'], ['Page-Hinkley_' atype]);
% end

disp('Using DG results path regardless of cfg.use_fband');
dp = fullfile(DATA_DIR, 'Szprec', pt_name, 'Processed',...
    [sz_name '_F'], ['Page-Hinkley_' atype]);
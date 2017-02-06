function [] = Szprec_ccm_process(sdir, ch_list)

global DATA_DIR;


% Get the defaults for analysis

cfg = cfg_default()

dp = fullfile(DATA_DIR,'Szprec', sdir, 'Data');
files = dir(fullfile(dp, '*.mat'));
if ~isempty(files)
    for j=1:numel(files)
        Szprec_ccm_single_seizure(files(j).name(1:end-4), ch_list)
    end
end            

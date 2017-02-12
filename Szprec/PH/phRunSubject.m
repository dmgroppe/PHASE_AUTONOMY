function [] = phRunSubject(pt_names, cfg)

if nargin < 2; cfg = cfg_default(); end;

if cfg.stats.use_max
    atype = 'max';
else
    atype = 'early';
end

for i=1:numel(pt_names)
    %list = szlist(pt_names{i});
    warning('Using Groppe hack because I do not have szlist.mat files for each patient.');
    list=get_szlist(pt_names{i});
    
    phProcess(list,1, cfg);
    phStats(list, atype, cfg, 1);
    rankOnSchematic(pt_names{i}, atype);
end
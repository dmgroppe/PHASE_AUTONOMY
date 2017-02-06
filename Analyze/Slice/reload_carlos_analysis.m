function [apc_infra apc_supra] = reload_carlos_analysis(Dir, fname)

[~, apc] = excel_read(Dir,fname);
apc_supra = set_analysis_channel(apc, 'supra');
apc_infra = set_analysis_channel(apc, 'infra');
function [ExportDir] = export_dir_get(dap)

ed = user_data_get('ExportDir');
if isempty(ed)
    ExportDir = get_sf_val(dap, 'ExportDir');
else
    ExportDir = ed;
end
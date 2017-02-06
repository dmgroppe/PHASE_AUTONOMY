function [] = rose_phase(phase)

h = figure(1);
rose(phase*ones(1,100));
save_figure(h, get_export_path_SMA(), 'ROSE PHASE');
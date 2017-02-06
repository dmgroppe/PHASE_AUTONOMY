function [] = Szprec_rundir(ddir, edir, cfg)

files = dir([ddir '*.mat']);

if ~isempty(files)
    for i=1:numel(files)
        load([ddir files(i).name]);
        nchan = size(matrix_bi, 2);
        
        h = figure;
        F = Szprec(matrix_bi, Sf, 1:nchan, 1:nchan, cfg);
        save_figure(h, edir, [files(i).name(1:end-4) ' PRECURSOR'], true);
        
        h = figure;
        rank_channels(F, Sf, cfg.freqs, cfg.freqs);
        save_figure(h, edir, [files(i).name(1:end-4) ' Overall RANK'], true);
        
        h = figure;
        Szprec_rankts(F, Sf, cfg, cfg.freqs);
        save_figure(h, edir, [files(i).name(1:end-4) ' Time RANK'], false);
        
        h = figure;
        Sprec_tf(matrix_bi, Sf, cfg);
        save_figure(h, edir, [files(i).name(1:end-4) ' Bipolar chanels'], true);
    end
else
    display('No .mat files found in this directory');
end
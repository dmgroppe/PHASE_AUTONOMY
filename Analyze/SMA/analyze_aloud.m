function analyze_aloud(EEG, nfig, atype)

tstart = 310000;
tend = 320000;

aparams = get_default_params();

aparams.sync.lowcut = 120;
aparams.sync.highcut = 145;
aparams.sync.ncycles = -1; % Just use the whole region and dont split it up
aparams.sync.poverlap = 0.5;


subr = get_subregion(EEG, tstart, tend);
sync_matrix(subr, EEG.srate, aparams, nfig, atype);
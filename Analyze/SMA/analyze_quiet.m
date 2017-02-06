function analyze_quiet(EEG, atype)

tstart = 410000;
tend = 420000;

aparams = get_default_params();

aparams.pc.lowcut = 95;
aparams.pc.highcut = 105;

subr = get_subregion(EEG, tstart, tend);
sync_matrix(subr, EEG.srate, aparams, nfig, atype);
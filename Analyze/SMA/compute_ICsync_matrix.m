function [sync,hs] = compute_ICsync_matrix(EEG, cond, frange, length)

[tstart tend] = get_trange(cond, length);
aparams = get_default_params();

aparams.sync.lowcut = frange(1);
aparams.sync.highcut = frange(2);

fprintf('%s %4.0f-%4.0fHz IC', upper(cond),...
            aparams.sync.lowcut, aparams.sync.highcut);
        
subr = get_subregion(EEG, tstart, tend);
subr = subr(1:EEG.nbchan-1,:);

[sync, hs] = sync_matrix(subr, EEG.srate, aparams, 'ic');
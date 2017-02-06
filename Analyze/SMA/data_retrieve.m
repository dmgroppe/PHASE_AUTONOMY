function [subr] = data_retrieve(EEG, cond, slength, ptname)
% Get the data
[tstart tend] = get_trange(cond, slength, ptname);
subr = get_subregion(EEG, tstart, tend);
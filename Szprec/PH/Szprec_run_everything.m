function [] = Szprec_run_everything(sz_list)

% Redo the full analysis for all the patients seizures listed in sz_list

Szprec_ph_fullanalysis(sz_list);
Szprec_tf_recompute(sz_list);
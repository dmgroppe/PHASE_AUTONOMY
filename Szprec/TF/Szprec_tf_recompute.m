function [] = Szprec_tf_recompute(sz_list)

% Recomputes all the TF spectra for pre and start options, all TF files are
% over written

tic
for i=1:numel(sz_list)
    display(sprintf('--- Recomputing TF spectra for patient %s...', strtok(sz_list{i}{1},'_')));
    Szprec_ph_tf_stats(sz_list{i}, 'start', 1, 0);
    Szprec_ph_tf_stats(sz_list{i}, 'pre', 1, 0);
    close all;
end
toc


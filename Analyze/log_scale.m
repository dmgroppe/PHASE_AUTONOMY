function [scales] = log_scale(sstart, noctaves, nvoices)

% [scales] = LogScale(sstart, noctaves, nvoices)
% sstart - start scale
% noctaves - number of octaves
% nvoices - number of voices per octave

scaleinc = 1/nvoices;
scales = sstart:scaleinc:noctaves;
scales = 2.^scales;
scales = sort(scales, 'descend');

%semilogy(scales, freqs);



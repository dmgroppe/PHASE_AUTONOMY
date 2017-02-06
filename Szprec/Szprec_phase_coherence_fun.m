function [F] = Szprec_phase_coherence_fun(wt, i1, srate, cfg)

% Precursor function

nchan = size(wt,3);

F = zeros(size(wt,1), size(wt,2), nchan-i1);
c = 0;
for j=(i1+1):nchan
    c = c+1;
    F(:,:,c) = phase_coherence(wt(:,:,i1), wt(:,:,j), srate, cfg);
end

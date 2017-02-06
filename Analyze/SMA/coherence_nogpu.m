% USAGE: [coh] = coherence(x1, x2)
function [coh] = coherence_nogpu(h1, h2)

dphi = angle(h1) - angle(h2);
r1 = abs(h1);
r2 = abs(h2);

cross_spec = r1.*r2.*exp(1i*dphi);

coh = mean(abs(cross_spec./sqrt((mean(r1.^2)*mean(r2.^2)))));
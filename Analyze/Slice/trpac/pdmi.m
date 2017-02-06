function [pdmi, pdmi_phase, p, surr_mi] = pdmi(h1, h2, a3, nbins, nsurr, ap)

% Hybrid calculation using PDPC ideas and MI but use the two signals x1 and x2 to obtain
% the good phase, and bins the amplitude of x3 accordingly.  Then uses the
% MI computation to determine if there is modulation of h3 by the departure from the "good
% phase" between h1 and h2 

if nargin < 6; ap = sl_sync_params(); end;

if nargin < 5;
    dop = 0;
    nsurr = 0;
else
    dop = 1;
end;
 
    

dphi = phase_diff(angle(h1) - angle(h2));

mean_phase = angle(sum(exp(1i*dphi)));
dphi = dphi-mean_phase;
dphi = phase_diff(dphi);

[mi, p, surr_mi] = sync_mi(dphi, a3, nbins, nsurr, dop, ap);
pdmi = mi.tort;
pdmi_phase = mi.phase;



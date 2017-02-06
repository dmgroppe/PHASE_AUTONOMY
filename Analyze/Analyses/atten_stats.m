function [] = atten_stats(alpha, nfig, aparams1, aparams2)

R1 = atten_collapse_condition(aparams1);
R2 = atten_collapse_condition(aparams2);

% Set the stats structure to pass information
stats.R1 = R1;
stats.R2 = R2;
stats.aparams1 = aparams1;
stats.aparams2 = aparams2;
stats.nfig = nfig;
stats.norm = aparams1.ana.norm;
stats.alpha = alpha;

stats.atype = 'power';
show_atten_stats(stats);

%stats.nfig = nfig+2;
%stats.atype = 'cvar';
%show_atten_stats(stats);
return;

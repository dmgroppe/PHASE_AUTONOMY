function [] = Szprec_run(list)
%function [] = Szprec_run(list)
%
% Analysis master function. Run this to reduplicate full analysis
%
% Input:
%  sdir - cell array of case codenames (e.g., {'AB','ST'}
%


Szprec_process(list);
Szprec_rankts_process(list);
function [franges] = franges()

franges = struct('ID', {1,2,3,4,5,6,7}, 'lb', {1,4,9,13,21,35,55}, 'ub', {3,8,12,20,30,50,100},...
    'Name', {'Delta','Theta','Alpha','Beta 1','Beta 2' 'Low Gamma', 'High Gamma'});
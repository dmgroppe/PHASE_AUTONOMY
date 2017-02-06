function [amps tintervals rho p] = peds(case_num, frange, revrel)

srate = 1000;
bins = 20;

if nargin < 4; revrel = 0; end;

fname = sprintf('D:\\Projects\\Data\\Peds\\case%d.mat', case_num);
load(fname);

vname = genvarname(sprintf('Case%d',case_num));
% put the dat into a local variable;
data = eval(vname);

for i=1:size(data,2)
    [amps{i} tintervals{i}] = sync_pfc(data(:,i), srate, frange);
end

% Reverse the relationship
if revrel
    for i=1:size(data,2)
        tintervals{i} = tintervals{i}(2:end);
        amps{i} = amps{i}(1:end-1,:);
    end
end


for i=1:size(data,2)
    [rho(i), p(i)] = corr(amps{i}',tintervals{i}','type','Spearman');
end


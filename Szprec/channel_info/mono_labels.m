function [enames] = mono_labels(varargin)


% If this is passed as another argument before then extract the cells
if numel(varargin) == 1
    varargin = varargin{1};
end

if mod(numel(varargin), 2)
    display('Incomplete channel input');
    return;
end

nelectrodes = numel(varargin)/2;
n = cell2struct(varargin,'arg', 1);
enumbers = [n(2:2:end).arg];

ecount = 0;
for i=1:nelectrodes
    for j=1:enumbers(i)
        ecount = ecount + 1;
        if i==9
            a = 1;
        end
        enames{ecount,:} = sprintf('%s%d', n(2*i-1).arg, j);
    end
end




function [S] = zap_run(Dir, fn, dolist, doplot)

if nargin < 4; doplot = 0; end;

if nargin <3
    dolist = 1:numel(Dir);
end

tic
nCells = numel(Dir);
for i=1:nCells;
    if ~isempty(find(dolist == i))
        [ss ap] = excel_read(Dir{i}, fn{i});
        if ~ss.error
%             for j=1:numel(ap)
%                 ap(i).Dir = Dir{i};
%             end
            for k = 1:numel(ap)
                ap(k).Dir = Dir{i};
            end
            %ap.Dir = Dir{i};
            S{i} = sl_zap_group(ap, doplot);
        else
            display(sprintf('Count not find file %d', i));
            S{i} = {};
        end 
    else
        display('Error')
        S{i} = {};
    end
end
toc



function [] = find_file_duplicates(dap)

nlines = numel(dap);

allfiles = {};

count = 0;
for i=1:nlines
    for j=1:numel(dap(i).cond.fname)
        all_files{i,j} = dap(i).cond.fname{j};
    end
end

[~,ncond] = size(all_files);


for i=1:ncond
    all_files(cellfun(@isempty,all_files(:,i))) = 'empty';
    all_files(:,i) = sort(all_files(:,i));
end

ndup = 0;
for i=1:ncond
    for j=1:nlines-1
        if all_files{j,i} == all_files{j+1,i};
            % This means there is a duplicate
            ndup = ndup+1;
            dups{ndup} = all_files{j,i};
        end
    end
end

udups = unique(dups);
dups(cellfun(@isempty,dups)) = [];



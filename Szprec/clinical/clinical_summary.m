function [clinical] = clinical_summary(pt_name, sz_name, summary)

% Gets or sets clinical data.  I left the summary aspect very generic so
% that it could be highly structured or free text

global DATA_DIR;

clinical = [];
filename = fullfile(DATA_DIR, 'Szprec', pt_name, [pt_name '_clinical.mat']);

if exist(filename, 'file')
    load(filename);
end

if nargin < 2
    % Just return the existing clinical information (empty if no info
    % found)
    return;
end

changed = false;

if ~isempty(clinical)
    ind = find_text({clinical.sz_name}, sz_name);
    if ind
        r = input('Summary already exists, replace (y/n): ', 's');
        if isempty(r);
            r = 'y';
        end;

        r = lower(r);
        switch r
            case 'y'
                clinical(ind).summary = summary;
                changed = true;
            case 'n'
                display('No changes being made.')
                return;
        end
    else
        display('Adding a new entry...')
        clinical(end+1).sz_name = sz_name;
        clinical(end).summary = summary;
        changed = true;
    end
else
    clinical.sz_name = sz_name;
    clinical.summary = summary;
    changed = true;
end


if changed
    % save if changed
    display('Saving changes...')
    save(filename, 'clinical');
end


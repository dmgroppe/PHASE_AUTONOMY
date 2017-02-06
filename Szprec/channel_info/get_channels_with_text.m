function [ch_labels, ind] = get_channels_with_text(pt_name, t, ch_type)

% Get the channel labels
[R] = names_from_bi_index(1, pt_name);
if ~isempty(R)
    switch ch_type
        case 'bipolar'
            ch_labels = R.bi_labels;
        case'mono'
            ch_labels = R.m_labels;
    end
end

nlabels = numel(ch_labels);

if isempty(t)
    ind = [];
    return;
elseif length(t) == 1
    % return the labels that start with this single letter
    ind = [];
    for i=1:nlabels
        if ch_labels{i}(1) == t(1);
            ind = [ind i];
        end
    end
else
    % Search all the labels for the substring t
    k = strfind(ch_labels, t);
    ind = cellfun('isempty',k);
    ind = find(ind == 0);
end
    

function [ap] = set_analysis_channel(ap, chtype)

% Takes an array of aps and sets the analysis channel to the channel that
% has label chtype;

for i=1:numel(ap)
    chnumber = find_text(ap(i).chlabels, chtype);
    if chnumber
        ap(i).ch = chnumber;
    else
        display(sprintf('%s - Did not find channel of type %s', ap(i).cond.fname{1}, chtype));
    end
end
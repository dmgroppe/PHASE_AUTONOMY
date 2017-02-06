function [] = plot_tags(dap, ap, yrange)

% Plots the user defined tags that were read in from the excel spreadsheet
% The tag has to have the format time1=tag1;time2=tag2...  There can be no
% spaces in the tags therefore underscores must be used for spaces

tagstr = get_sf_val(dap, 'Tags');
if ~isempty(tagstr)
    tag = tags_get(tagstr);
    for i=1:numel(tag)
        line([tag{i}{1} tag{i}{1}], yrange, 'Color','k', 'LineStyle', '--');
        text(double(tag{i}{1}), mean(yrange),tag{i}{2}, ap.pl.textprop, ap.pl.textpropval, ...
            'HorizontalAlignment', 'center');
    end
end
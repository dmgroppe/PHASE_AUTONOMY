function [] = xlim_set_all_figs(handles, xl)

if isempty(handles)
    handles = findobj('Type','figure');
end

if ~isempty(handles)
    for i=1:length(handles)
        figure(handles(i));
        xlim(xl);
    end
end
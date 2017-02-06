function [] = figuresSave(handles)

global FIGURE_DIR;

display('Saving figures...');
for i=1:numel(handles)
    save_figure(handles(i).h, FIGURE_DIR, handles(i).name,handles(i).saveeps);
end
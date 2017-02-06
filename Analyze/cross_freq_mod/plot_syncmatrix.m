function [] = plot_syncmatrix(sm, cax)

if nargin < 2; cax = []; end;

if (max(max(sm)) == min(min(sm)))
    display('No range to sync matrix, nothing to plot.')
    return;
end

set(gcf, 'Renderer', 'zbuffer');
nchan  = length(sm);
surf(sm);
view(0,90);
axis equal
axis([1 nchan 1 nchan]);
if ~isempty(cax)
    caxis(cax);
end
xlabel('Channel number');
ylabel('Channel number');
colorbar;

% rectangle('Position',[1,1,32,64], 'LineWidth',2, 'EdgeColor', 'w');
% rectangle('Position',[1,1,64,32], 'LineWidth',2, 'EdgeColor', 'w');
% 
% rectangle('Position',[1,32,64,4], 'LineWidth',2, 'EdgeColor', 'w'); 
function [] = plot_ranges(ranges, yaxis, direction, r_type, color, alpha)

% Plots ranges on a plot with either a patch or rectangle

if nargin < 6; alpha = 0.2; end;
if nargin < 5; color = 'k'; end;
if nargin < 4; r_type = 'rect'; end;
    
hold on
for i=1:size(ranges,2) 
    x = [repmat(ranges(1,i),1,2) repmat(ranges(2,i),1,2)];
    y = reshape([yaxis fliplr(yaxis)], 1, 4);
    z = ones(1,4);
       
    if strcmp(direction, 'vert')
        if strcmp(r_type, 'rect')
            rect = [ranges(1,i), yaxis(1), ranges(2,i)-ranges(1,i), yaxis(2)-yaxis(1)];
            rectangle('Position',rect, 'LineWidth',1, 'EdgeColor', color);
        else
            patch(x,y,z, color, 'FaceAlpha', alpha, 'EdgeColor', 'none');
        end
    else
        if strcmp(r_type, 'rect')
            rect = [yaxis(1), ranges(1,i), yaxis(2)-yaxis(1), ranges(2,i)-ranges(1,i)];
            rectangle('Position',rect, 'LineWidth',1, 'EdgeColor', color);
        else
            patch(y,x,z,color, 'FaceAlpha', alpha, 'EdgeColor', 'none');
        end
    end
    
end

hold off
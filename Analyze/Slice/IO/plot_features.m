function [M V N] = plot_features(all_features, nspikes, features, norm_data)

% Get the averages, stds, and number of elements
[M N V] = feature_average(all_features, nspikes, features);

if ~norm_data
    [r c] = rc_plot(numel(features));
    for i=1:numel(features)
        subplot(r,c,i);
        if ~(numel(find(M(:,i) == 0)) == size(M,1))
            barweb(M(:,i),V(:,i), 0.5, [], []);
            
            title(features(i));
            xlabel('Spike#');
            axis square;
        end
    end   
else
    barweb(M',V', 0.5, features, []);
    axis square;  
end


% cmap = colormap(lines); 
% subplot(3,2,[1 3 5]);
% if sp_type == 3
%     plot(all_features(sp,1), all_features(sp,2),'.', 'LineStyle' ,'none', 'MarkerSize', 6, ...
%         'Color', [0.7 0.7 0.7]);
% else
%     plot3(all_features(sp,1), all_features(sp,2),all_features(sp,3), '.', 'LineStyle' ,'none', 'MarkerSize', 6, ...
%         'Color', [0.7 0.7 0.7]);
% end
% hold on;
%     
% for i=1:nspikes
%     sp = find(all_features(:,sp_type) == i);
%     if sp_type == 3
%         plot(all_features(sp,1), all_features(sp,2),'.', 'LineStyle' ,'none', 'MarkerSize', 6, ...
%             'Color', cmap(i,:));
%     elseif sp_type == 4
%         plot3(all_features(sp,1), all_features(sp,2), all_features(sp,3),'.', 'LineStyle' ,'none', 'MarkerSize', 6, ...
%             'Color', cmap(i,:));
%     end
%     
%     for j = 1:sp_type-1
%         M(i,j) = mean(all_features(sp,j));
%         V(i,j) = std(all_features(sp,j))/sqrt(length(sp));
%     end
% end
% 
% sp = find(all_features(:,sp_type) > nspikes);
% 
% for j = 1:sp_type-1
%     M(nspikes+1,j) = mean(all_features(sp,j));
%     V(nspikes+1,j) = std(all_features(sp,j))/sqrt(length(sp));
% end
% view([135 30]);
% hold off;
% axis square;
% 
% % Label the axes
% xlabel(features{1});
% ylabel(features{2});
% if numel(features) == 3
%     zlabel(features{3});
% end


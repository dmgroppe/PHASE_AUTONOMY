function [all_pts patch_h] = events_get()
count = 0;
all_pts = [];
patch_h = [];

while 1
    display('Select a point to demarcate the start of an event');
    
    pts = ginput(1);
    count = count + 1;
    display(sprintf('%d events selected.', count));
    
    all_pts(:,count) = pts';
    assignin('base', 'all_pts', all_pts);
    
    
%     patch_h(count) = patch([pts(1,1) pts(1,1) pts(2,1) pts(2,1)],[pts(:,2)' fliplr(pts(:,2)')],'green', 'FaceAlpha', 0.3,...
%             'EdgeColor', 'none');

    patch_h(count) = line([pts(1,1) pts(1,1)], ylim,'LineWidth', 2, 'Color', [1 0 0]);
    assignin('base', 'patch_h', patch_h);

    ch = getkey;   
    switch ch
        case 97 % '(s)djust
            input('Hit any key to continue after adjusting');
        case 27  % ESC
            return;
        case 100 % d for delete
            if count > 0
                all_pts(:,count) = [];
                delete(patch_h(count));
                patch_h(count) = [];
                count = count - 1;
                display('Last point deleted')
            end
        otherwise
            continue;
    end
end

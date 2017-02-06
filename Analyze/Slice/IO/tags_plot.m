function [] = tags_plot(h, hdr, c)

if nargin < 3; c = 'g'; end;

ntags = numel(hdr.tags);

figure(h);
tflag = 0;
for i=1:ntags
    x = hdr.tags(i).properTime;
    if tflag
        y = max(ylim)-0.2*max(ylim);
        tflag = 0;
    else
        y = min(ylim)+ 0.2*max(ylim);
        tflag = 1;
    end;
    
    text(x, y, hdr.tags(i).comment, 'FontSize', 7, 'FontName', 'Small Fonts',...
        'Color', c);
    line([x x], ylim, 'Color', c);
end


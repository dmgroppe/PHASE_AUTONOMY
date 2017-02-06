function [] = save_figure(h, dir, title, saveeps, exp_type, res, rend_mode)

% USAGE: save_figure(h, dir, title, saveeps, exp_type, res, rend_mode)
%
% h             - figure handle
% dir           - directory to save the file to
% saveeps       - save as a vector file (both eps and emf
% exp_type      - type of bitmap to export to '-djpeg', '-dpng' etc 
% res           - bitmap resolution
% render_mode   - ie. -painters, -zbuffer etc

if nargin < 7; rend_mode = '-painters';end;
if nargin < 6
    resolution = '-r300';
else
    resolution = sprintf('-r%d', res);
end

if nargin < 5; exp_type = '-djpeg'; end;
if nargin < 4; saveeps = 1; end;


fullpath = fullfile(char(dir), char(title));

if saveeps
    print(h, '-depsc', rend_mode, fullpath);
    print(h, '-dmeta', rend_mode, fullpath);
end
print(h, exp_type, rend_mode, resolution, fullpath);



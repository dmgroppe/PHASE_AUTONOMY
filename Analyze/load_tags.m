% USAGE: function [retval, tags] = load_tags(fn)
%   Loads tags exported from ANA
%   INPUT:
%           fn:     Full pathname to the tag file
%   OUTPUT:
%       retval:     0 if no file loaded, 1 if everything okay
%       tags:       Cell array of tags
%
%------------------------------------------------------------------

function [tags] = load_tags(fn)

lines_per_epoch = 4;

tag = struct('ch', {0}, 'ep', {0}, 'limits', {[]}, 'valid', {0}, 'markers', {[]});
tags = [];

if (~exist(fn, 'file'))
    display(sprintf('Unable to open: %s', fn));
    return;
end

flines = importdata(fn);
[lines,c] = size(flines);
if (mod(lines,lines_per_epoch) ~= 0)
    display('Incorrect number of entries:');
    return
end

nepochs = lines/lines_per_epoch;
tags = cell(1,nepochs);

for i=1:nepochs
    start_line = (i-1)*lines_per_epoch + 1;
    tag.markers = flines(start_line, 1:10);
    tag.ch = flines(start_line+1, 1);
    tag.ep = flines(start_line+1, 2);
    tag.limits = flines(start_line+2, 1:2);
    tag.valid = flines(start_line+3, 1);
    tags{i} = tag;
end
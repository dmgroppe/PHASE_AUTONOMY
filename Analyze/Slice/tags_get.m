function [tags] = tags_get(str)

remain = str;

count = 0;
tags = {};

while ~isempty(remain)
     [token remain] = strtok(remain,';');
     if ~isempty(token)
         count = count + 1;
         tags{count} =  textscan(token,'%d=%s');
     end
end
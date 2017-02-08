function [day, szr]=day_and_szr_from_filename(fname)
%function [day, szr]=day_and_szr_from_filename(fname)
%
% Extracts the day and seizure number from a filename such as SV_d1_sz1.mat
%
% Author: DG



und_ids=find(fname=='_');
day_str=fname(und_ids(1)+2:und_ids(2)-1);
day=str2num(day_str);
dot_id=find(fname=='.');
szr_str=fname(und_ids(2)+3:dot_id-1);
szr=str2num(szr_str);

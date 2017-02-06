function [pairs] = pairs_get(location, ptname, S)

if nargin < 2; ptname = 'vant'; end;
if nargin < 3; S = []; end;


switch lower(ptname)
    case 'vant'
        switch location
            case 'inside'
                pairs = pairs_all([7 8 15 16 59 60 61]);
            case 'outside'
                pairs = pairs_all([1:6,9:14,17:22,24:31,33:58,62:64]);
            case 'all'
                pairs = pairs_all([1:22,24:31,33:64]);
            case 'local'
                if ~isempty(S)
                    pairs = connections_local(S);
                else
                    pairs = [];
                end
        end
    case 'nourse'
        switch location
            case'inside'
                % All pairs that had positive mappings
                %pairs = pairs_all([4 5 6 7 8 12 13 14 15 16 48 49]);
                
                % Only those that show significant power increases from
                % ps_compare analyses
                pairs = pairs_all([4 5 6 7 8 12 16 48 49]);
            case 'outside'
                % Leave out the most rostral 3 rows, and in the inside
                % contacts
                pairs = pairs_all([20:24,28:62]);
            case 'all'
                pairs = pairs_all([4:8,12:16,20:24,28:62]);
            case 'local'
                if ~isempty(S)
                    pairs = connections_local(S);
                else
                    pairs = [];
                end
        end
end
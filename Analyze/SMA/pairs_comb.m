function [out_pairs] = pairs_comb(p1, p2, type)

switch type
    case 'union'
        out_pairs = union(p1', p2', 'rows')';
    case 'intersect'
        out_pairs = intersect(p1', p2', 'rows')';
    case 'diff'
        out_pairs = setdiff(p1', p2', 'rows')';
    case 'setxor'
        out_pairs = setxor(p1', p2', 'rows')';
    otherwise
        display('Improper command for pairs_organize');
end
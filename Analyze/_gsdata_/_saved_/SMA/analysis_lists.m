function [A] = analysis_lists(ptname)

switch lower(ptname)
    case 'vant'

        A.flist(:,1) = [62 73];
        A.flist(:,2) = [92 107];
        A.flist(:,3) = [126 166];
        A.flist(:,4) = [200 500];
        A.flist(:,5) = [60 500];
        %A.fnames = {'mu', 'beta', 'g1', 'g2', 'g3', 'g4'};
        A.fnames = {'g1', 'g2', 'g3', 'g4', 'BB'};
    case 'nourse'
        A.flist(:,1) = [53 62];
        A.flist(:,2) = [111 127];
        A.flist(:,3) = [200 500];
        A.flist(:,4) = [60 500];
        %A.fnames = {'mu', 'beta', 'g1', 'g2', 'g3', 'g4'};
        A.fnames = {'g1', 'g2', 'g3', 'BB'};
end

A.condlist = {'aloud' 'quiet', 'rest_eo', 'rest_ec'};
A.atypes = {'ic', 'pc', 'corr'};
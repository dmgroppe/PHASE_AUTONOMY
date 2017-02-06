function [R] = loadR(layer, aType)

global DATA_DIR

R = {};

aPath = fullfile(DATA_DIR, '\Human recordings\ZAP function\Analyzed\');

fname = sprintf('R_L%d_%s', layer, aType);

inFile = fullfile(aPath, [fname '.mat']);

if ~exist(inFile, 'file')
    error('The specified analysis was not found');
end

load(inFile);
evalc(sprintf('R = %s', fname));

goodCells = 1:numel(R);
switch layer
    case 23
        switch aType
            case 'sub_rmp'
                goodCells = [1 2 3 4 5 6 9 10, 12, 13 14 15 17 19 20 22 23 24 25 26 28 32 35 36 37 39 40];
            case 'sub_80'
                goodCells = [2 4 7 8 9 10 11 12 13] ;
        end
end

R = R(goodCells);

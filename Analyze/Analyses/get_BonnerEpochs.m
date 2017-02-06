% USAGE:    [R] = get_BonnerEpochs(test, cond, aparams)
%
%   Input:
%       test:       the test state 'face' or 'scene;
%       cond:       condition either 'face' or 'scene'
%       aparams:    analysis paramters
%   Output:
%       R:          Cell array of the epochs and other analysis parameters


function [R] = get_BonnerEpochs(test, cond, aparams)

R = {};

switch test
    case 'face'
        aparams.ana.test = 'Face1';
        aparams.ana.cond = cond;  % Can be face or scene
        R{1} = RunBonnerAnalysis(aparams);

        aparams.ana.test = 'Face2';
        aparams.ana.cond = cond;  % Can be face or scene
        R{2} = RunBonnerAnalysis(aparams);
    case 'scene'
        aparams.ana.test = 'Scene2';
        aparams.ana.cond = cond;  % Can be face or scene
        R{1} = RunBonnerAnalysis(aparams);

        aparams.ana.test = 'Scene3';
        aparams.ana.cond = cond;  % Can be face or scene
        R{2} = RunBonnerAnalysis(aparams);
    case 'passive'
        aparams.ana.test = 'passive1';
        aparams.ana.cond = cond;  % Can be face or scene
        R{1} = RunBonnerAnalysis(aparams);

        aparams.ana.test = 'passive2';
        aparams.ana.cond = cond;  % Can be face or scene
        R{2} = RunBonnerAnalysis(aparams);
end
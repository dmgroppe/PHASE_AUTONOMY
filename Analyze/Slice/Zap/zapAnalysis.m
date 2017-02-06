function [R] = zapAnalysis(dDir, doplot)

global DATA_DIR;
global COMPUTERNAME;

if nargin < 2; doplot = 0; end;

if strcmpi(COMPUTERNAME,'SUPER')
    subDir1 = '\Human Recordings\ZAP function';
else 
    subDir1 = '\ZAP function\';
end

fullDir = fullfile(DATA_DIR, subDir1, dDir);
if ~exist(fullDir, 'dir');
    error('Directory does not exit');
end

fileNames = dir(fullfile(fullDir, '*.abf'));

for i=1:numel(fileNames);
    fileNumbers(i) = str2double(fileNames(i).name(end-7:end-4));
end

cellBorders = find(diff(fileNumbers) ~= 1);
nCells = length(cellBorders);
cellBorders(end+1) = numel(fileNames);

for i=1:nCells
    if i == 1
        cellInd{i} = 1:cellBorders(1);
    elseif i == nCells
        cellInd{i} = (cellBorders(i)):(cellBorders(i+1));
    else
        cellInd{i} = (cellBorders(i)):(cellBorders(i+1)-1);
    end
end

% Compute the impedence across all cells for all trials performed for that
% cell

parfor i=1:nCells
    display(sprintf('Working on cell 1 of %d - %s', i, nCells));
    c = 0;
    for j=cellInd{i}(1):cellInd{i}(end)
        c = c+1;
        R{i}{c} = zap_run_sigle_file(fullDir, fileNames(j).name(1:end-4));
    end
end

display('Saving results...')
save(fullfile(fullDir,'zap_results.mat'),'R', 'fullDir', 'fileNames', 'cellInd');

% display('Plotting...');
% if doplot
%     zap_plot(R, fullDir);
% end
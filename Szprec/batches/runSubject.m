function [] = runSubject(pt_name, sz_list, aCfg)

% Run full PH analysis on a single subject

global DATA_DIR;

if nargin < 2; aCfg = cfg_default; end;

% Make the various directory names
proc_dir = fullfile(DATA_DIR, 'Szprec', pt_name, 'Processed');
ad_dir = fullfile(DATA_DIR, 'Szprec', pt_name, 'Processed\Adaptive deriv');


% Run the various analyses.  Important to note that all the patients
% seizure are analyzed and ranked.  However only a subset in sz_list are
% processed for statistics

processDir(pt_name, aCfg);
ranktsProcess({pt_name}, 1);

% Get the list of files in the Processed directory
fdir = dir(proc_dir);

% If the Adaptive deriv folder does not exist make it
if ~exist(ad_dir, 'dir')
    mkdir(ad_dir);
end

% MOve the analyzed folder to Adaptive deriv folder
for i=3:numel(fdir)
    if fdir(i).isdir
        if strcmpi(strtok(fdir(i).name, '_'), pt_name)
            movefile(fullfile(proc_dir,fdir(i).name), ad_dir);
        end
    end
end

% Get the appropriate seizure list
for i=1:numel(sz_list)
    if strcmpi(strtok(sz_list{i}{1}, '_'), pt_name)
        szlist = sz_list{i};
        break;
    end
end

% Do page hinkley analysis
pHprocess(szlist, 1,aCfg);
phStats(szlist, 'early',aCfg, 1);

% Plot on the schematic
rankOnSchematic(pt_name, 'early');
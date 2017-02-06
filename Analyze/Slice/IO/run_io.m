function [R] = run_io(Dir, eDir, dosave)

if nargin < 2; dosave = false; end;
if nargin < 3; eDir = '';end;

files = dir([Dir '*.abf']);

% Strip the file extension off..
dfiles = {files(:).name};
for i=1:numel(dfiles)
    dfiles{i} = dfiles{i}(1:end-4);
end

% Read in the parameters
[params txt ~] = xlsread([Dir 'IVparams.xlsx'], 1);
ap = sl_sync_params();
R = [];

if strcmpi(txt{1}, 'Filename')
    ind_sub = 1;
else
    ind_sub = 0;
end

xfiles = {txt{1+ind_sub:size(txt,1)}};
for i=1:numel(xfiles)
    xfiles{i}(find(isspace(xfiles{i}) == 1)) = [];
    xfiles{i} = xfiles{i}(1:end-1);
end


% Compare files in directory to those in spreadsheet
err = 0;
for i=1:length(dfiles);
    ind = find_text(xfiles,dfiles{i});
    if ~ind
        err = 1;
        display(sprintf('File %s found in data dir was not found in XLSX file.',dfiles{i}));
    else
        if params(ind,5) ~= 1
            display(sprintf('%s not to be included in analyses', dfiles{i}));
        end
    end
end

for i=1:length(xfiles);
    ind = find_text(dfiles, xfiles{i});
    if ~ind
        err = 1;
        display(sprintf('File %s found in data dir was not found in XLSX file.',xfiles{i}));
    else
        if params(i,5) ~= 1
            display(sprintf('%s not to be included in analyses', xfiles{i}));
        end
    end
end


if err
    display('Mismatch between spreadsheet and data dirctory.');
    display('Only those files in directory that have entries in XLS file will be analyzed');
end

c = 0;
for i=1:length(dfiles);
    ind = find_text(xfiles,dfiles{i});
    if ind
        ap.io.pulsestart = params(ind,1);
        ap.io.pulsedur = params(ind,2);
        ap.io.pampstart = params(ind,3);
        ap.io.pampstep = params(ind,4);
        
        if params(ind,5)
            c = c + 1;
            [R(c).S, R(c).spikes, R(c).mp] = slice_io(Dir,eDir, dfiles{i}, ap, dosave);
            R(c).ap = ap;
            R(c).fname = dfiles{i};
            R(c).Dir = Dir;
            R(c).eDir = eDir;
        else
            display(sprintf('Did not process: %s',dfiles{i}));
        end
    end
end

display(sprintf('%d files processed', c));

if ~isempty(R)
    save([Dir 'Spike_Analysis.mat']);
end
function [hdr, d, si, ap] = io_load(Dir, fn)
% Function to load a data file, and it's waveform protocol from an XLSX
% file
% USAGE: [hdr, d, si, ap] = io_load(Dir, fn)

ap = sl_sync_params();

fpath = [Dir fn '.abf'];
if ~exist(fpath, 'file')
    display('File does not exits');
    return;
end

% Make sure the program doe snot bomb even if there is an error reading in
% the file
try
    [d,si,hdr]=abfload(fpath);
catch
    display('Error loading the file, although it does exist');
    d = [];
    si = [];
    hdr = [];
end

% Ensure it is in waveform mode
if hdr.nOperationMode ~= 5
    % Means that data were acquired in some other mode than that required
    % for I/O
    display('Data not acquired in: waveform fixed-length mode');
    return;
end

%------------Compute a few constants -----------------------%

[npoints nchan nepochs] = size(d);
hdr.lNumSamplesPerEpisode = npoints;
hdr.nADCNumChannels = nchan;
hdr.lActualEpisodes = nepochs;

% Try to get the waveform protocol from the same directory
% get the default ap

if ~exist([Dir 'IVparams.xlsx'], 'file');
    display('Unable to load waveform from XLSX file...')
    return;
end

[params txt ~] = xlsread([Dir 'IVparams.xlsx'], 1);


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

ind = find_text(xfiles, fn);
if isempty(ind)
    display('Filename not found in the XLSX file...')
    return;
end

display('Waveform sucessfully read in from file.')

ap.io.pulsestart = params(ind,1);
ap.io.pulsedur = params(ind,2);
ap.io.pampstart = params(ind,3);
ap.io.pampstep = params(ind,4);


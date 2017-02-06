function [] = dir_text_to_mat(pt_name, Sf_line_number, numberofheaderlines)

% USAGE: dir_text_to_mat(pt_name, Sf_line_number, numberofheaderlines)
%
% Converts ASCII text files exported from XLTEK clinical system to mono and
% bipolar derivations and saves in MATLAB file of the same name.  Processes
% an entire directory.  The 'group_end_index', needs to created first
% using 'make_channel_info'.
%
% pt_name               Abbreviated patient name
% Sf_line_number        Line number for the sampling rate
% numbeofheaderlines    Number of lines to skip before getting to the data
%
%   Taufik A Valiante (2015) with initial code from Frank Ye

global DATA_PATH;

% Default to 9 (standard)
if nargin < 4; numberofheaderlines = 15; end;
if nargin < 3; Sf_line_number = 7; end;

% Machine specific data path
dpath = fullfile(DATA_PATH, 'Szprec', pt_name);

% get the .txt files
ffile = fullfile(dpath, 'Data', '*.txt');
fnames = dir(ffile);
numfids = numel(fnames);

% Check to see if there are any files (or maybe the path is wrong)
if ~numfids
    display(sprintf('No files found for %s', ffile));
    return;
end

% Get group_end_index from the channel_info file
chinfo_path = fullfile(dpath, [pt_name '_channel_info.mat']);
if ~exist(chinfo_path, 'file')
    error('No channel info file found');
else
    load(chinfo_path, 'group_end_index');
end

% Last value in group_end_index is the last channel
channelnumbers = group_end_index(end);

% Process the files
for i = 1:numfids
    fpath = fullfile(dpath, 'Data', fnames(i).name);
    display(sprintf('Converting file %d of %d - %s',i,numfids, fnames(i).name));
    
    % Get the sampling rate
    fileID = fopen(fpath);
    format = ['%s%s%s' repmat('%f', [1 1]) '%*[^\n]'];
    Sf = textscan(fileID,format,'HeaderLines', Sf_line_number);
    Sf = Sf{4}(1);
    fclose(fileID); 
    
    % Get the data points
    fileID = fopen(fpath);
    format = ['%*s%*s%*s' repmat('%s', [1 channelnumbers]) '%*[^\n]'];
    c = textscan(fileID,format,'HeaderLines', numberofheaderlines);
    temp=c{1,1};
    matrix_mo=zeros(length(temp),channelnumbers);
    
    tic
    parfor j=1:channelnumbers    
        mono=c{1,j};
        matrix_mo(:,j)=str2double(mono);
        matrix_mo(:,j) = remove_nans(squeeze(matrix_mo(:,j)));
    end
    toc
    
    fclose(fileID);
       
    % Convert to bi-polar
    matrix_bi =  mono_to_bipolar(matrix_mo, group_end_index);
    
    % Save the data
    save(fullfile(dpath, 'Data', [fnames(i).name(1:end-4) '.mat']),'Sf','matrix_mo', 'matrix_bi', 'group_end_index');
   
    % Plot the data as a sanity check - hopefully somebody is watching!   
    h = figure(1);clf;
    set(h, 'Name', fnames(i).name);
    ax(1) = subplot(2,1,1);
    Szprec_tf(matrix_mo, Sf, cfg_default);
    title('Monopolar channels');
    set(gca, 'TickDir', 'out');

    ax(2) = subplot(2,1,2);
    Szprec_tf(matrix_bi, Sf, cfg_default);
    title('Bipolar channels');
    set(gca, 'TickDir', 'out');
    
    drawnow;
end
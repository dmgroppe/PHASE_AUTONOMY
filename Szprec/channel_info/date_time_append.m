function [] = date_time_append(pt_name, line_number)

global DATA_DIR;

if nargin < 2; line_number = 10; end;

ddir =fullfile(DATA_DIR, 'Szprec', pt_name, 'Data', '*.txt');
dfiles = dir(ddir);


for i=1:numel(dfiles)
    fname = dfiles(i).name(1:end-4);
    infile = make_data_path(fname, 'text_data');
    dfile = make_data_path(fname, 'data');

    fileID = fopen(infile);
    format = ['%s%s%s' repmat('%f', [1 1]) '%*[^\n]'];
    Sf = textscan(fileID,format,1, 'HeaderLines', line_number);
    fclose(fileID); 

    date_time = [Sf{1}{1} ' ' Sf{2}{1}];
    display(sprintf('%s: %s', fname, date_time));

    if exist(dfile, 'file')
        save(dfile, 'date_time', '-append');
    else
        display('Data file does not exist');
    end
end
function [retval] = check_ana_params(params)

retval = 0;
inFile = [params.ana.dataDir params.ana.dataFile];

if (~exist(inFile, 'file'))
    display(sprintf('Unable to open, %s', inFile));
    return;
end

tagFile = [params.ana.dataDir params.ana.tagFile];

if (~exist(tagFile, 'file'))
    display(sprintf('Unable to open, %s', tagFile));
    return;
end

if(~params.ana.fixed_length)
    display('Only fixed length analyses supported at this time.');
    return;
end

retval = 1;

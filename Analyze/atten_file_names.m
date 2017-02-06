function [params] = atten_file_names(params)

global COMPUTERNAME;

if (~strcmp(COMPUTERNAME, 'SUPER-UNIX'))
    params.ana.dataDir = sprintf('D:\\Projects\\Data\\Attention\\%s\\', params.ana.subjectname);
    params.export.dir = sprintf('D:\\Projects\\Data\\Attention\\%s\\Analyzed\\', params.ana.subjectname);
else
    params.ana.dataDir = sprintf('/media/HDD/Projects/Data/Attention/%s/', params.ana.subjectname);
    params.export.dir = sprintf('/media/HDD/Projects/Data/Attention/%s/Analyzed/', params.ana.subjectname);
end

params.ana.dataFile = sprintf('%s.mat', params.ana.test);
params.ana.tagFile = sprintf('%s tags.txt', params.ana.test);
params.export.prefix = sprintf('%s %s %s',params.ana.subjectname, params.ana.test, params.ana.cond);
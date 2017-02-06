function [params] = set_file_names(params)

params.ana.dataDir = sprintf('D:\\Projects\\Data\\Scene memory\\Data\\%s\\%s\\', params.ana.subjectname, params.ana.test);
params.export.dir = sprintf('D:\\Projects\\Data\\Scene memory\\TVA\\%s\\', params.ana.test);

params.ana.dataFile = sprintf('%s %s.mat', params.ana.subjectname, params.ana.test);
params.ana.tagFile = sprintf('%s %s tags.txt',params.ana.subjectname, params.ana.test);
params.export.prefix = sprintf('%s %s',params.ana.subjectname, params.ana.cond);
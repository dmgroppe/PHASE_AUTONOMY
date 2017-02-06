function [ap] = processedPath(sz_name)

% Builds the procssed path from golbal variables

pt_name = strtok(sz_name, '_');

global DATA_DIR;
global PROCESSED_DIR;

subdir = sprintf('\\Szprec\\%s\\Processed\\%s\\%s_F', pt_name, PROCESSED_DIR,sz_name);
ap = fullfile(DATA_DIR, subdir);


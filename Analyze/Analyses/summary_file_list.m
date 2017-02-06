function [sf] = summary_file_list(test, condition, anat_loc)

sf.names = ['As'; 'Cu'; 'Mc'; 'Pr'; 'Sa'; 'Si'; 'St'];
sf.test = test;
sf.cond = condition;
sf.anat_loc = anat_loc;

sf.nsubjects = length(sf.names);
sf.inDir = sprintf('D:\\Projects\\Data\\Scene memory\\TVA\\%s\\', sf.test);

sf.ch = cell(1,sf.nsubjects);
sf.ch{1} = [2 9 7];         % As
sf.ch{2} = [1 9 7];         % Cu
sf.ch{3} = [1 9 16];        % Mc
sf.ch{4} = [1 9 7];         % Pr
sf.ch{5} = [20 23 27];      % Sa
sf.ch{6} = [36 43 41];      % Si
sf.ch{7} = [1 9 7];         % St

% Sa has a different neocortical electrode for recognition
if (strcmp(sf.test, 'rec'))
    sf.ch{5} = [20 23 29];      % Sa
end

sf.files = cell(1,sf.nsubjects);

for i=1:sf.nsubjects
    if (strcmp(sf.anat_loc,'HP'))
        ch_n = sf.ch{i}(1);
    elseif (strcmp(sf.anat_loc,'EC'))
        ch_n = sf.ch{i}(2);
    else
        ch_n = sf.ch{i}(3);
    end
    sf.files{i} = sprintf('%s%s %s CH%d.mat',sf.inDir, sf.names(i,:),sf.cond, ch_n);
end



% USAGE: atten_collpase_condition()
%  Computed the bootstrap significance within condition
%  Combined the various trials together first
%   Input:
%       subjectname:    self explanatory
%       test:           either 'face', 'scene', or 'passive'
%       cond:           either 'face' or 'scene'
%   indicies:           the indicies of the tests 1, 2, etc etc

function [R] = atten_collapse_condition(aparams)

%aparams = get_default_params();
%test = 'face';

%aparams.ana.subjectname = subjectname;
%aparams.ana.cond = cond;  % Can be face or scene
%aparams.ana.test_index = indicies;

nfiles = length(aparams.ana.test_index);
R.spectra = [];
spectra_list = cell(1,length(aparams.ana.test_index)); % Contains the spectra for each item of the list
test = aparams.ana.test;

for i=1:length(aparams.ana.test_index)
    aparams.ana.test = sprintf('%s%d', test, aparams.ana.test_index(i));
    aparams = atten_file_names(aparams);
    fn = sprintf('%s%s CH%d.mat', aparams.export.dir, aparams.export.prefix, aparams.ana.atten_channel);
    if (~exist(fn, 'file'))
        display(fn);
        display('File does not exist.');
        R.spectra = [];
        return
    end
    load(fn);
    R.frq = frq;
    R.al_list{i} = alimit_list;
    R.param_list{i} = params;
    if (exist('pl_stats', 'var'))
        R.pl_stats_list{i} = pl_stats;
    end
    spectra_list{i} = spectra;
end

total_spectra = 0;
nspeclist = zeros(1,nfiles);

for i=1:nfiles
    [nfrq,npoints,nspectra] = size(spectra_list{i});
    R.nspeclist(i) = nspectra;
    total_spectra = total_spectra + nspectra;
end

R.spectra = zeros(nfrq,npoints,total_spectra);

for i=1:nfiles
    if (i==1)
        sstart = 1;
        send = R.nspeclist(1);
    else
        sstart = sum(R.nspeclist(1:i-1))+1;
        send = sum(R.nspeclist(1:i));
    end
        
    R.spectra(:,:,sstart:send) = spectra_list{i};
end



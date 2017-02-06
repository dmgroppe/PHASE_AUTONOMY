% USAGE: [pl] = phase_sync(sf, aparams)
%
%   Computes the ps (phase synchrony) between two channels and across two
%   conditions
%
%   Input:
%       sf:         The file names
%       aparams:    Analysis parameters

function [pl plm frq indicies dparams] = phase_sync(sf, aparams)

pl = {};    % Contains the pl stats (condition, subject)
plm = {};   % Contains the raw binned matricies
nsubjects = sf{1,1}.nsubjects;
indicies = cell(2,nsubjects);
for i=1:2
    % loop over the conditions
   
    for j=1:nsubjects
        % Get the spectra and get the concordent epoch indices
        display(sprintf('File 1: %s.',sf{1,i}.files{j}));
        display(sprintf('File 1: %s.',sf{2,i}.files{j}));
        [inds, s, frq, dparams] = get_spectra_indices(sf{1,i}.files{j}, sf{2,i}.files{j});
        indicies{i,j} = inds;
        
        display(sprintf('Computing phase locking for cond %d, subject %d.', i,j));
        
        [nfrq, npoints,~] = size(s{1});
        
        pd = zeros(nfrq, npoints, length(inds));
        for k=1:length(inds)
            pd(:,:,k) = phase_diff(angle(s{1}(:,:,inds(1,1,k))) - angle(s{2}(:,:, inds(1,2,k))));
        end
        
        % Compute the PL statistics for the phase differences of the two
        % channels
        
        [pl{i,j} plm{i,j}] = compute_pl(pd, aparams, 'diff');
    end
end

function [indicies s frq params] = get_spectra_indices(f1, f2)
    if (~exist(f1, 'file') || ~exist(f2, 'file'))
        error('Unable to open one or both of the files for ps calculations');
    end
    
    load(f1);
    alimit1 = alimit_list;
    s{1} = spectra;
    load(f2);
    alimit2 = alimit_list;
    s{2} = spectra;
    
    display(sprintf('%d epochs for file 1, %d epochs for file 2.',length(alimit1),length(alimit2)));
    
    indicies = [];
    nindicies = 0;
    for i=1:length(alimit1)
        for j=1:length(alimit2)
            if (alimit1{i}.ep == alimit2{j}.ep)
                nindicies = nindicies + 1;
                indicies(:,:,nindicies) = [i j];
                break;
            end
        end
    end
    
    display(sprintf('%d coincident epochs.', nindicies));
    
function [] = comod_stats(frq, param_list, mod_phase, mod_str)

params = param_list{1,1};
nsubjects = length(mod_str);
nfrq = length(mod_str{1,1});

findex = input('Enter array of frequencies [xstart xend ystart yend]: ');
while (~isempty(findex))
    if (length(findex) < 4)
        display('Two few arguments.');
        continue;
    end
    % This a problem here since frq contains the frequencies from scal2frq
    % and thus do not correspond exactly to user defined frequencies AND it
    % assumes that the default frequencies form 1:100 by 1Hz is being used.
    
    M1 = zeros(1,nsubjects);
    M2 = zeros(1,nsubjects);
    for i=1:nsubjects
        M1(i) = mean(mean(mod_str{i,1}(findex(3):findex(4), findex(1):findex(2))));
        M2(i) = mean(mean(mod_str{i,2}(findex(3):findex(4), findex(1):findex(2))));
    end
    
    permd = zeros(1,2*nsubjects);
    permd(1:nsubjects) = M1;
    permd(nsubjects+1:end) = M2;
    [test,prob,thresh] = perm_anova(permd', nsubjects, 1, 2, 1000, .05);
    display(sprintf('p = %4.3f', prob));
    
    findex = input('Enter specific freqeuncy to analyze (Hz): ');
end


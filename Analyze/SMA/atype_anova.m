function [] = atype_anova()

nfreq = 6;
natype = 3;
ncond = 4;

% rows = # conditions (aloud, quiet...) * #atypes(IC, PC, CORR)
% columns = nfreq
cfactor =zeros(ncond*natype,nfreq);
rfactor = cfactor;

rcount = 0;
for i=1:atype
    for j=1:ncond
        rcount = rcount + 1;
        rfactor(rcount,:) = i*ones(1,nfreq);
        for k = 1:nfreq
            cfactor(rcount, k)
        end
    end
end
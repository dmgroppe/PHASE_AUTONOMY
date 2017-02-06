function [p] = two_sided_perm(R1, R2, aparams, dparams)

[nfrq, npoints, nspectra1] = size(R1);
[nfrq, npoints, nspectra2] = size(R2);

nspectra = min([nspectra1 nspectra2]);
blsamples = time_to_samples(dparams.ana.baseline, dparams.data.srate);

cond{1} = R1(:,:,1:nspectra);
cond{2} = R2(:,:,1:nspectra);
p = zeros(nfrq, npoints);

if (aparams.ana.normtobl)
    z0 = norm_to_bl(mean(R1, 3),blsamples) - norm_to_bl(mean(R2,3), blsamples);
else
    z0 = mean(R1, 3) - mean(R2,3);
end


for i=1:aparams.ana.nsurr
    if ( mod(i,100) == 0)
        display(sprintf('Permutation %d of %d', i, aparams.ana.nsurr));
    end
    [rl] = flip(nspectra);
    for j=1:nspectra
        if (rl.flip(j))
            temp = cond{2}(:,:,j);
            cond{2}(:,:,j) = cond{1}(:,:,j);
            cond{1}(:,:,j) = temp;
        end
    end
    if (aparams.ana.normtobl)
        z = norm_to_bl(mean(cond{1}, 3), blsamples) - norm_to_bl(mean(cond{2},3), blsamples);
    else
        z = mean(cond{1}, 3) - mean(cond{2},3);
    end

    ind = find(z > z0);
    p(ind) = p(ind) + 1;
end

p = (1+p)./(aparams.ana.nsurr+1);


function [rl] = flip(nspectra)

rl.flip = zeros(1, nspectra);

for i=1:nspectra
    if (rand < 0.5)
        rl.flip(i) = 0;
    else
        rl.flip(i) = 1;
    end
end



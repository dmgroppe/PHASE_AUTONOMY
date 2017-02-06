function [sorted_isi] = isi_sort(R)
% Column 1 = ISI
% Column 2 = epoch number (1 = first time an ISI occurs)
% Column 3 = ISI number within the epoch

isi = isi_collapse(R);
epoch_nmax = max(isi(:,2));
spike_max = max(isi(:,3));

for e=1:epoch_nmax
    icount = 0;
    for i=1:spike_max
        ep_ind = find(isi(:,2) == e);
        isi_ind = find(isi(:,3) == i);
        ind = intersect(ep_ind,isi_ind);
        if ~isempty(ind)
            icount = icount+1;
            sorted_isi{e}{icount} = isi(ind,1);
        else
            sorted_isi{e}{icount} = isi(ind,1);
        end
    end
end
function [isi] = isi_collapse(R)

isi = [];
count = 0;
% Interate over each cell
for i=1:numel(R)
    ecount = 0;
    for j=1:numel(R(i).S.isi)
        if ~isempty(R(i).S.isi{j})
            ecount = ecount + 1;
            for k =1:numel(R(i).S.isi{j})
                count = count + 1;
                isi(count,:) = [R(i).S.isi{j}(k) ecount k];
            end
        end
    end
end
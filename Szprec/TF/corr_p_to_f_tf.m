function [c, freqs] = corr_p_to_f_tf(S, a_cfg)

nsz = numel(S);
nchan = numel(S{1});
[freqs,~,b] = intersect(a_cfg.freqs, a_cfg.stats.ph_tf_freqs);

c= zeros(length(b), 2, nchan, nsz);
c = NaN;
for i=1:nsz
    for j=1:nchan
        if numel(S{i}(j).seg)
            for k= 1:numel(S{i}(j).seg)
                for f = 1:length(b)
                    %display(sprintf('i=%d,j=%d,k=%d',i,j,k));
                    p = zscore(S{i}(j).p{k}(b(f),:));
                    prec = zscore(S{i}(j).f{k}(f,:));
                    c(f,k,j,i) = xcorr(p, prec,0,'coeff');
                end
            end
        else
            c(:,:,j,i) = NaN;
        end
        %imagesc(mean(c(:,:,j,:),4));colorbar
    end
end

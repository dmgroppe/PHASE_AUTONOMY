function [] = pdmi_summary(R, dap, ap)

condnames = {'Baseline', 'K', 'K+C'};
ch_names = {'supra', 'infra'};
alpha = .05;
stringent =0;

nchan = numel(ch_names);
nslices = numel(R);

pdmi = NaN*ones(length(ap.trpac.wt_lfrange),numel(condnames), nchan, nslices);
phase = pdmi;

badslices = [];
for i=1:nslices
    r = R{i};
    ncond = numel(r);
    for j=1:ncond
        cond_ind = find_text(condnames, r{j}.cond);
        if ~isempty(cond_ind)
            r_cond = r{j};
            for k=1:nchan
                ch_ind = find_text(ch_names, dap(i).chlabels{k});
                if ~isempty(ch_ind)
                    %pdmi(:,cond_ind, ch_ind, i) = zscore(abs(r_cond.pdmi(:,ch_ind)));
                    pdmi(:,cond_ind, ch_ind, i) = abs(r_cond.pdmi(:,ch_ind));
                    phase(:,cond_ind,ch_ind,i) = r_cond.phase(:,ch_ind);
                    
                    if cond_ind == 1
                        n = pdmi(:,cond_ind, ch_ind, i);
                        pdmi(:,cond_ind, ch_ind, i) = ones(length(ap.trpac.wt_lfrange),1);
                    else
                        pdmi(:,cond_ind, ch_ind, i) = pdmi(:,cond_ind, ch_ind, i)./n;
                    end
                    
                    if max(pdmi(:,cond_ind, ch_ind, i)) > 5000
                        badslices = [badslices i];
                        pdmi(:,cond_ind, ch_ind, i) = NaN;
                    end
                else
                    display(sprintf('dap #%d - A channel was not indexed properly', i));
                end
            end
        else    
            display(sprintf('dap #%d - A condition was not indexed properly', i))
        end
    end
end

m = nanmean(pdmi,4);
sem = nanstd(pdmi,1,4)/sqrt(nslices);
sem_p = permute(sem,[1 3 2]);

% Plots the PDMI with confidence limits
zpdmi = pdmi;
zpdmi(isnan(zpdmi)) = 0;

pcond = {'B vs K', 'B vs K+C', 'B k vs K+C'};

for l=1:nchan
    ax(2*l-1) = subplot(4,1,2*l-1);
    boundedline(ap.trpac.wt_lfrange, squeeze(m(:,:,l)), sem_p(:,l,:));
    title(upper(ch_names{l}));
    xlabel('Frequency(Hz)');
    ylabel('PDMI');
    %axis([xlim 0 3e-3])
    
    count = 0;
    for c1 =1:ncond
        for c2 = c1+1:ncond
            count = count + 1;
            for f = 1:length(ap.trpac.wt_lfrange)
                [p(f,count,l), ~] = ranksum(squeeze(zpdmi(f,c1,l,:)), squeeze(zpdmi(f,c2,l,:)));
            end
            pfdr(:,count,l) = fdr_vector(p(:,count,l), alpha, stringent);
        end
    end
    
    ax(2*l) = subplot(4,1,2*l);
    plot(repmat(ap.trpac.wt_lfrange,3,1)', squeeze(pfdr(:,:,l)))
    legend(pcond);
    ylabel('Sig');
    xlabel('Freqeuncy (Hz)');
end

linkaxes(ax, 'x');





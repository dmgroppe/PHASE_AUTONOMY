function [Rsum] = trpac_summary(R, dap)

if nargin < 3; norm = 1; end;

alpha = 0.01;

condnames = {'Baseline', 'K', 'K+C'};
ch_names = {'supra', 'infra'};
ap = sl_sync_params();

nchan = numel(ch_names);
nslices = numel(R);

pc = cell(numel(condnames),1);
pac = cell(numel(ch_names),numel(condnames));

cond_sig = zeros(numel(ch_names),numel(condnames));
cond_rho = zeros(numel(ch_names),numel(condnames));
pk_loc = zeros(numel(ch_names),numel(condnames), nslices);
pk_val = zeros(numel(ch_names),numel(condnames), nslices);



for i=1:nslices
    r = R{i};
    ncond = numel(r);
    for j=1:ncond
        
        cond_ind = find_text(condnames, r(j).cond);
        if ap.trpac.zscore
            pc{cond_ind,1} = [pc{cond_ind,1} zscore(r(j).corr.pc(:)')];
        else
            pc{cond_ind,1} = [pc{cond_ind,1} r(j).corr.pc(:)'/max(r(j).corr.pc(:)')];
        end
        
        % Just collect all the pc's
        pc_all{cond_ind,i} = r(j).pc;
        
        clfranges(:,cond_ind,i)= r(j).clfrange;
        
        if ~isempty(cond_ind)
            for k=1:nchan
                ch_ind = find_text(ch_names, dap(i).chlabels{k});
                if ~isempty(ch_ind)
                    % Find how many significant layers per condition
                    cond_sig(ch_ind,cond_ind) = cond_sig(ch_ind,cond_ind) + (r(j).corr.pval(k) <= alpha);
                    
                    % PAC summary
                    % Sum over all R values for cond and channels to get
                    % average
                    cond_rho(ch_ind, cond_ind) = cond_rho(ch_ind, cond_ind) + fisherZ(r(j).corr.rho(k));
                    if ap.trpac.zscore
                        pac{ch_ind,cond_ind} = [pac{ch_ind,cond_ind} zscore(r(j).corr.pac(k,:))];
                    else
                        pac{ch_ind,cond_ind} = [pac{ch_ind,cond_ind} r(j).corr.pac(k,:)/max(r(j).corr.pac(k,:))];
                    end
                    
                    % Collect all PAC's
                    pac_all{ch_ind, cond_ind,i} = r(j).pac(k,:);
                    
                    % Peak analysis summary
                     pk_loc(ch_ind, cond_ind,i) = r(j).pk.loc_env(k);
                     pk_val(ch_ind, cond_ind,i) = r(j).pk.val_env(k);
                else
                    display(sprintf('dap #%d - A channel was not indexed properly', i));
                end
            end
        else    
            display(sprintf('dap #%d - A condition was not indexed properly', i))
        end
    end
end

h = figure(1);clf;
set(h, 'Name', 'PC-PAC summary');
count = 0;
for i=1:nchan
    for j=1:ncond
        count = count+1;
        subplot(nchan,ncond, count);
        plot(pac{i,j}, pc{j}, '.', 'LineStyle', 'none', 'MarkerSize', 5);
        title(sprintf('%s - %s', condnames{j}, ch_names{i}));
        if ap.trpac.zscore
            axis([-4 4 -4 4]);
        else
            axis([0 1 0 1]);
        end
        [rho, pval] = corr(pac{i,j}',pc{j}','type', 'Spearman');
                xlabel('PAC');
        n(i) = length(pac{i,j});        
        ylabel('PC');
        set(gca, 'TickDir', 'out');
        axis square;
        
        %[rho_surr p_surr] = perm_stats(Rsum.pac{i,j}',Rsum.pc{j}', ap.trpac.permstats_nsurr);
        %p_perm = sum(rho_surr > rho)/ap.trpac.permstats_nsurr;
        %legend(sprintf('r=%6.2f,p=%e,p_perm=%e', rho, pval, p_perm));
        legend(sprintf('r=%6.2f,p=%e', rho, pval));
        
%         hold on;
%         [xfit, yfit] = linear_fit(Rsum.pac{i,j}, Rsum.pc{j});
%         plot(xfit, yfit, 'r');
%         hold off;
    end
end

h = figure(2);clf;

for i=1:numel(condnames);
    set(h,'Name', 'HF envelope summary');
    subplot(3,1,i);
    plot(squeeze(pk_loc(1,i,:)), squeeze(pk_loc(2,i,:)), '.', 'LineStyle', 'none',...
        'MarkerSize', 5);
    axis([1 20 1 20]);
    axis square;
    [rho p] = corr(squeeze(pk_loc(1,i,:)), squeeze(pk_loc(2,i,:)), 'type', 'Spearman');
    title(sprintf('rho = %6.2f, %6.2f', rho, p));
end

% Area analyses

h = figure(3);clf;
for s=1:nslices
    for c=1:ncond
        area_pc(c,s) = simps(pc_all{c,s});
        mean_pc(c,s) = mean(pc_all{c,s});
        for l=1:nchan
            area_pac(l,c,s) = simps(pac_all{l,c,s});
            mean_pac(l,c,s) = mean(pac_all{l,c,s});
        end
    end 
end

count = 0;
for l=1:nchan
    for c = 1:ncond
        count = count + 1;
        subplot(nchan, ncond,count);
        zpac = zscore(squeeze(area_pac(l,c,:)));
        %zpac = squeeze(mean_pac(l,c,:));
        zpc = zscore(squeeze(area_pc(c,:)));
        plot(zpac, zpc, '.', 'LineStyle', 'none', 'MarkerSize', 5);
        xlabel('PAC');
        ylabel('PC');
        title(sprintf('%s-%s', condnames{c}, ch_names{l}))
        axis([-4 4 -4 4]);
        axis square;
        
        [rho p] = corr(zscore(squeeze(area_pac(l,c,:))), zscore(squeeze(area_pc(c,:)))', 'type', 'Spearman');
        legend(sprintf('r=%6.2f,p=%e', rho, pval));
        
    end
end


Rsum.cond_sig = cond_sig;
Rsum.cond_rho = cond_rho/nslices;
Rsum.pc = pc;
Rsum.pac = pac;
Rsum.clfranges = clfranges;
Rsum.pk_loc = pk_loc;
Rsum.pk_val = pk_val;
Rsum.pc_all = pc_all;
Rsum.pac_all = pac_all;
Rsum.area_pc = area_pc;
Rsum.area_pac = area_pac;



function [xfit, yfit] = linear_fit(x, y)
np = length(x);
X = [ones(1,np)' x'];
b = regress(y',X);
xfit = min(x):0.05:max(x);
yfit = b(1) + b(2)*xfit;

function [rho p] = perm_stats(x,y, nsurr)

npoints = length(x);
for i=1:nsurr
    rind = randperm(npoints);
    [rho(i) p(i)] = corr(x(rind), y, 'type', 'Spearman');
end


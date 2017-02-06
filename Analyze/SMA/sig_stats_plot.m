function [] = sig_stats_plot(atype)

A = analysis_lists();
roi = [7 8 15 16 59 60 61];
A.flist = [];
A.flist(:,1) = [128 156];

%atypes = size(A.atypes,2);
nfranges = size(A.flist,2);
ncond = size(A.condlist, 2);


for i=1:nfranges
    for j=1:ncond
        Sh{j,i} = sig_stats_get(atype, A.condlist{j}, A.flist(:,i), roi, 0.05, 1);
        if isempty(Sh{j,i})
            display('DATA missing: Can not proceed with plotting.')
            return;
        end
    end
end

for i=1:nfranges
    for j=1:ncond
        if (Sh{j,i}.in.n == 0 || Sh{j,i}.out.n == 0)
            in_mean = 0;
            out_mean = 0;
            in_var = 0;
            out_var = 0;
        else
            in_mean = Sh{j,i}.in.mean;
            in_var = Sh{j,i}.in.var;
            out_mean = Sh{j,i}.out.mean;
            out_var = Sh{j,i}.out.var;
        end
        
        % Compute the standard errors
        if (Sh{j,i}.in.n == 0)
            in_se = 0;
        else
            in_se = sqrt(in_var/Sh{j,i}.in.n);
        end
        
        if (Sh{j,i}.out.n == 0)
            out_se = 0;
        else
            out_se = sqrt(out_var/Sh{j,i}.out.n);
        end
     
        summary(:,j,i) = [in_mean, out_mean, in_se, out_se];
    end
end

h = figure(1);
text = sprintf('%s - IN vs OUT Comparisons', upper(atype));
set(h, 'Name', text);

for i=1:ncond
    pmean = squeeze(summary(1:2,i,:))';
    perror = squeeze(summary(3:4,i,:))';
    subplot(2,2,i);
    if (min(min(pmean) ~= max(max(pmean))))
        barweb(pmean, perror,1,A.fnames);
    end
    
    switch atype
        case 'ic'
            axis([0 nfranges+1 0 0.25]);
        case 'wpli'
            axis([0 nfranges+1 0 0.5]);
        case 'corr'
            axis([0 nfranges+1 0 0.25]);
        case 'pc'
            axis([0 nfranges+1 0 0.5]);
        otherwise
            axis([0 nfranges+1 0 max(max(pmean)) + max(max(perror))]);
    end
end

eDir = get_export_path_SMA();
save_figure(h ,eDir, text);

function [] = mi_combine()

plap = sl_sync_params();
[~, ap] = excel_read('D:\Projects\Data\Human Recordings\Files for First paper\Spreadsheets\','Carlos Analysis_Reviewed');

R_supra = get_mis(ap, 'D:\Projects\Data\Human Recordings\Analyzed\MI Supra\', 'SUPRA');
R_infra = get_mis(ap, 'D:\Projects\Data\Human Recordings\Analyzed\MI Infra\', 'INFRA');

S_supra = mi_stats(R_supra);
S_infra = mi_stats(R_infra);

[C]= collect_stats(S_supra, S_infra, R_supra);
[P] = run_stats(C, R_supra, 'K+C');

if numel(R_supra) ~= numel(R_infra)
    display('DIfferent number of elements for layers');
    return;
end

nslices = numel(R_supra);

lfrange = R_supra(1).ap.mi.lfrange;
hfrange = R_supra(1).ap.mi.hfrange;

for i=1:nslices
    h1 = figure(1);
    set(h1, 'Visible', 'off');
    clf
    ncond = numel(ap(R_supra(i).id).cond.names);
    fname = sprintf('%s COMBINED MI', ap(R_supra(i).id).cond.fname{1});
    set(h1, 'Name', fname);
    for j = 1:ncond
        subplot(ncond,2,2*j-1);
        if max(max(R_supra(i).psig{j})) == 1
            plot_mi(lfrange, hfrange, R_supra(i).mi{j}.*R_supra(i).psig{j});
            title(sprintf('SUPRA SIG- %s', ap(R_supra(i).id).cond.names{j}), plap.pl.textprop, plap.pl.textpropval);
        else
            plot_mi(lfrange, hfrange, R_supra(i).mi{j});
            title(sprintf('SUPRA RAW- %s', ap(R_supra(i).id).cond.names{j}), plap.pl.textprop, plap.pl.textpropval);
        end
        set(gca, plap.pl.textprop, plap.pl.textpropval);
        
        subplot(ncond,2,2*j);
        if max(max(R_infra(i).psig{j})) == 1
            plot_mi(lfrange, hfrange, R_infra(i).mi{j}.*R_infra(i).psig{j});
            title(sprintf('INFRA SIG- %s', ap(R_infra(i).id).cond.names{j}), plap.pl.textprop, plap.pl.textpropval);
        else
            plot_mi(lfrange, hfrange, R_infra(i).mi{j});
            title(sprintf('INFRA RAW- %s', ap(R_infra(i).id).cond.names{j}), plap.pl.textprop, plap.pl.textpropval);
        end
        set(gca, plap.pl.textprop, plap.pl.textpropval);
    end
    save_figure(h1,export_dir_get(R_supra(i).ap), fname);
    
    
    % Plot the phase information
    
    h2 = figure(2);
    set(h2, 'Visible', 'off');
    clf;
    fname = sprintf('%s COMBINED PHASE', ap(R_supra(i).id).cond.fname{1});
    set(h2, 'Name', fname);
    
    for j = 1:ncond
        subplot(ncond,2,2*j-1);
        if max(max(R_supra(i).psig{j})) == 1
            plot_mi(lfrange, hfrange, R_supra(i).phase{j}.*R_supra(i).psig{j});
            caxis([-pi pi]);
            title(sprintf('SUPRA SIG- %s', ap(R_supra(i).id).cond.names{j}), plap.pl.textprop, plap.pl.textpropval);
        else
            plot_mi(lfrange, hfrange, R_supra(i).phase{j});
            caxis([-pi pi]);
            title(sprintf('SUPRA RAW- %s', ap(R_supra(i).id).cond.names{j}), plap.pl.textprop, plap.pl.textpropval);
        end
        set(gca, plap.pl.textprop, plap.pl.textpropval);
        
        subplot(ncond,2,2*j);
        if max(max(R_infra(i).psig{j})) == 1
            plot_mi(lfrange, hfrange, R_infra(i).phase{j}.*R_infra(i).psig{j});
            caxis([-pi pi]);
            title(sprintf('INFRA SIG- %s', ap(R_infra(i).id).cond.names{j}), plap.pl.textprop, plap.pl.textpropval);
        else
            plot_mi(lfrange, hfrange, R_infra(i).phase{j});
            caxis([-pi pi]);
            title(sprintf('INFRA RAW- %s', ap(R_infra(i).id).cond.names{j}), plap.pl.textprop, plap.pl.textpropval);
        end
        set(gca, plap.pl.textprop, plap.pl.textpropval);
    end
    save_figure(h2,export_dir_get(R_supra(i).ap), fname);
end

function [C]= collect_stats(S1, S2, R)
nslices = numel(R);
[uconds]= unique_conds(R);


for i = 1:numel(uconds)
    for j=1:nslices
        cindex = find_text(R(j).data_ap.cond.names, uconds{i});
        if cindex
            if S1(cindex,j).mi.sigavg ~= -1
                C.mi1(cindex,j) = S1(cindex,j).mi.sigavg;
                C.rmax1(cindex,j) = S1(cindex,j).mi.rmax;
                C.cmax1(cindex,j) = S1(cindex,j).mi.cmax;
            else
                C.mi1(i,j) = 0;
                C.rmax1(cindex,j) = 0;
                C.cmax1(cindex,j) = 0;
            end
            if S2(cindex,j).mi.sigavg ~= -1
                 C.mi2(cindex,j) = S2(cindex,j).mi.sigavg;
                 C.rmax2(cindex,j) = S2(cindex,j).mi.rmax;
                 C.cmax2(cindex,j) = S2(cindex,j).mi.cmax;
            else
                C.mi2(i,:) = 0;
                C.rmax2(cindex,j) = 0;
                C.cmax2(cindex,j) = 0;
            end
        end
    end
end

function [P]= run_stats(C, R, condition)

[uconds]= unique_conds(R);
cindex = find_text(uconds, condition);

if cindex
    % Do the MI stats
    ind1 = find (C.mi1(cindex,:) ~= 0);
    ind2 = find (C.mi2(cindex,:) ~= 0);

    if isempty(ind1) || isempty(ind2)
      P = [];
    else
      P.mi.pts1 = C.mi1(cindex,ind1);
      P.mi.pts2 = C.mi2(cindex,ind2);
      P.mi.p = ranksum(P.mi.pts1, P.mi.pts2);
      
      P.mi.lf1 = R(1).data_ap.mi.lfrange(C.cmax1(cindex,ind1));
      P.mi.lf2 = R(1).data_ap.mi.lfrange(C.cmax2(cindex,ind2));
      
      
    end
else
   P = []; 
end


function [S] = mi_stats(R)
nslices = numel(R);

% This get global maximum
for j = 1:nslices
    ncond = numel(R(j).mi);
    for i=1:ncond
        S(i,j).mi.max = max(max(R(j).mi{i}));
        [S(i,j).mi.rmax, S(i,j).mi.cmax] = find(R(j).mi{i} == S(i,j).mi.max);
    end
end

% Get the average mi of the significant regions
for j = 1:nslices
    ncond = numel(R(j).mi);
    for i=1:ncond
        if max(max(R(j).psig{i})) == 1
            ind = find(R(j).mi{i}.*R(j).psig{i} ~= 0);
            S(i,j).mi.sigavg = mean(R(j).mi{i}(ind));
            S(i,j).mi.sigstd = std(R(j).mi{i}(ind));
        else
            S(i,j).mi.sigavg = -1;
            S(i,j).mi.sigstd = -1;
        end
    end
end


function [uconds]= unique_conds(R)
conds = {};
% Get all the unique conditions
for i=1:numel(R)
    conds = [conds R(i).data_ap.cond.names];
end

uconds = unique(conds);

    


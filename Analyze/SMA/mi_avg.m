function [] = mi_avg(avg_list, acond, pmask, dosave)

if nargin < 4; dosave = 0; end;
if nargin < 3; pmask = 0; end;


% Averages the modulation index across slices.  User specified which slices
% to be combined in the average
%
% avg_list: cell array of the first file name in the excel spread sheet for
%           each of the individual slices.  These must be within the
%           filenames that have already been analyzed
% acond:    The condition for which the average is to be obtained


plap = sl_sync_params();
[R_supra, R_infra, ~, index_list] = get_mi_list(avg_list);

lfrange = R_supra(1).data_ap.mi.lfrange;
hfrange = R_supra(1).data_ap.mi.hfrange;

mi_supra = zeros(numel(hfrange), numel(lfrange));
mi_infra = mi_supra;

scount = 0;
icount = 0;

for i=1:numel(index_list)
    cindex = find_text(R_supra(index_list(i)).data_ap.cond.names, acond);
    mi_s = R_supra(index_list(i)).mi{cindex};
    mi_i = R_infra(index_list(i)).mi{cindex};
    psig_s = R_supra(index_list(i)).psig{cindex};
    psig_i = R_infra(index_list(i)).psig{cindex};
    
    if pmask
        if max(max(psig_s)) ~= 0
            scount = scount + 1;
            mi_supra = mi_supra + normalize_mi(mi_s.*psig_s);
        end
        if max(max(psig_s)) ~= 0
            icount = icount + 1;
            mi_infra = mi_infra + normalize_mi(mi_i.*psig_i);
        end
    else
        mi_supra = mi_supra + normalize_mi(R_supra(index_list(i)).mi{cindex});
        mi_infra = mi_infra + normalize_mi(R_infra(index_list(i)).mi{cindex});
    end
end

cmax = 1.5;

h = figure(1);
clf
set(h, 'Name', 'MI_AVG')
subplot(3,1,1);
plot_mi(lfrange, hfrange, mi_supra/scount);
set(gca, plap.pl.textprop, plap.pl.textpropval);
title('SUPRA');
caxis([0 cmax]);

subplot(3,1,2);
plot_mi(lfrange, hfrange, mi_infra/icount);
set(gca, plap.pl.textprop, plap.pl.textpropval);
title('INFRA');
caxis([0 cmax]);

subplot(3,1,3);
plot_mi(lfrange, hfrange, (mi_infra+mi_supra)/(scount+icount));
set(gca, plap.pl.textprop, plap.pl.textpropval);
title('COMBINED');
caxis([0 cmax]);

if dosave
    save_figure(h,export_dir_get(ap(1)), 'MI_AVG');
end

function [z] = normalize_mi(mi)

if max(max(mi)) == 0;
    z = mi;
    z(:,:) = 0;
else
    mi_v = reshape(mi,1,numel(mi));
    z = (mi - mean(mi_v))/std(mi_v);
end





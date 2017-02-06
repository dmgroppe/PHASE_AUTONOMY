function [] = feature_stats_2cells(c1, c2)

ap = sl_sync_params();
c1_spf = feature_summary(c1, sl_sync_params());
c2_spf = feature_summary(c2, sl_sync_params());

[nc1 nf1] = size(c1_spf);
[nc2 nf2] = size(c1_spf);

if (nf1 ~= nf2)
    display('Cells were analyzed sifferently');
    return;
end
nf = nf1;
clc;

for i=1:ap.io.firstspikestodisp
    sp1{i} = find(c1_spf(:,nf) == i);
    sp2{i} = find(c2_spf(:,nf) == i);
    sp_text{i} = sprintf('#%d', i);
end

sp1{ap.io.firstspikestodisp+1} = find(c1_spf(:,nf) > ap.io.firstspikestodisp);
sp2{ap.io.firstspikestodisp+1} = find(c2_spf(:,nf) > ap.io.firstspikestodisp);
sp_text{ap.io.firstspikestodisp+1} = sprintf('>=%d', ap.io.firstspikestodisp+1);

for i=1:ap.io.firstspikestodisp+1
    display(sprintf('SPIKE %d stats', i));
    for j=1:numel(ap.io.features)
        display(sprintf('    %s-------------', upper(ap.io.features{j})));
        [mx1(i,j) mx2(i,j) sem1(i,j) sem2(i,j)] = Ttest(c1_spf(sp1{i},j), c2_spf(sp2{i}, j));
        
        % Plot the AHP values
%         if j == 3
%             vals1 = c1_spf(sp1{i}, j);
%             vals1(find(vals1 == 0)) = [];
%             vals2 = c2_spf(sp2{i}, j);
%             vals2(find(vals2 == 0)) = [];
%             
%             subplot(1,ap.io.firstspikestodisp+1, i);
%             [n,xout] = hist(vals1, 20);
%             h = bar(xout, n/length(vals1), 'b');
%             get(h,'Type') %For illustration purpose only.
%             pH = arrayfun(@(x) allchild(x),h);
%             set(pH,'FaceAlpha',0.25); 
%              
%              
%              
%             
%             hold on;
%             [n,xout] = hist(vals2, 20);
%             bar(xout, n/length(vals2), 'g');
%             ylim([0 0.2]);
%         end
    end
end

h = figure(1);
clf;
[r, c] = rc_plot(numel(ap.io.features));
for i=1:numel(ap.io.features)
    subplot(r,c,i);
    barweb([mx1(:,i), mx2(:,i)] , [sem1(:,i) sem1(:,i)], 0.5, sp_text);
    title(ap.io.features{i});
end

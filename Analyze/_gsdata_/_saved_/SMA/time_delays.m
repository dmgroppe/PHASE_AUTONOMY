function [] = time_delays(ptname, condlist, p1, p2)

% Computes te statistics fo rth etime delays obtained rm the mean phase
% information obtained from the PPC analysis

dir = 'D:\Projects\Data\Vant\Figures\Super\PhasePowerCorr\Vant\FMC-SMA\';

R1 = load_ppc(dir, ptname, condlist{1}, p1);
R2 = load_ppc(dir, ptname, condlist{2}, p2);

if isempty(R1) ||isempty(R2)
    display('Unable to continue, exiting.');
end

nranges = size(R1.ap.extrema_range, 2);

for i=1:size(R1.ap.extrema_range, 2)
    index1 = find(R1.ap.freqs >= R1.ap.extrema_range(1,i) & R1.ap.freqs <= R1.ap.extrema_range(2,i));
    index2 = find(R2.ap.freqs >= R2.ap.extrema_range(1,i) & R2.ap.freqs <= R2.ap.extrema_range(2,i));
    
    v1{i} = R1.mean_angle(index1);
    v2{i} = R2.mean_angle(index2);
    
    t1{i} = v1{i}./(2*pi)./R1.ap.freqs(index1)*1000;
    t2{i} = v2{i}./(2*pi)./R2.ap.freqs(index2)*1000;
     
    mean1 = circ_mean(v1{i});
    %var1 = circ_var(R1.mean_angle(index1));
    
    mean2 = circ_mean(v2{i});
    %var2 = circ_mean(R2.mean_angle(index1));
    
    pa = circ_kuipertest(v1{i}, v2{i});
    pt = ttest2(t1{i}, t2{i});
    
    fprintf('\n Phase: Range %d %d-%d: mean1 = %6.2f, mean2 = %6.2f', i, R1.ap.extrema_range(1,i),...
        R1.ap.extrema_range(2,i), mean1, mean2);
    fprintf('\n  p = %e\n', pa);
    
     fprintf('\n Time: Range %d %d-%d: mean=%6.2f sem=%6.2f, mean2 = %6.2f, sem = %6.2f', i, R1.ap.extrema_range(1,i),...
        R1.ap.extrema_range(2,i), mean(t1{i}), std(t1{i})/sqrt(length(t1{i})), mean(t2{1})/sqrt(length(t2{i})));
     fprintf('\n  p = %e\n', pt);
   
    
end


% Compute the time differences
for i=1:nranges
    for j=i+1:nranges
        
        index1 = find(R1.ap.freqs >= R1.ap.extrema_range(1,i) & R1.ap.freqs <= R1.ap.extrema_range(2,i));
        index2 = find(R2.ap.freqs >= R2.ap.extrema_range(1,i) & R2.ap.freqs <= R2.ap.extrema_range(2,i));
        
        p1 = circ_kuipertest(v1{i}, v1{j});
        p2 = circ_kuipertest(v2{i}, v2{j});
        
        fprintf('\n For pair 1 range %d vs %d: p = %e',i, j, p1);
        fprintf('\n For pair 2 range %d vs %d: p = %e', i, j, p2);
    end
end


function [R] = load_ppc(dir, ptname, cond, ch)

fname = sprintf('Phase-power corr %s %s %d&%d', upper(ptname), upper(cond), ch(1), ch(2));

full_name = [dir fname '.mat'];

if exist(full_name, 'file')
    load(full_name);
else
    display(fname);
    display('File does not exist');
    R = [];
end

    


function [] = population_stats(Rs, pop_names, bparams)

if nargin <3
    bparams = {'resting', 'resistance'};
end
clc;
for i=1:numel(Rs)
    display(sprintf('-------------------Stats for %s-----------------', upper(pop_names{i})));
    [b{i} sm{i} ~] = stats_2nd_spike(Rs{i}, 1:numel(Rs{i}));
    biophys_b = biophys_collect(b{i}, bparams);
    biophys_sm = biophys_collect(sm{i}, bparams);
    display('SMALLER (X1) vs BIGGER (X2)');
    
    for j=1:numel(bparams)
        display(sprintf('  %s -----', upper(bparams{j})));
        Ttest(biophys_sm(:,j) , biophys_b(:,j));
    end
end

display(' ');
if numel(Rs) > 1
    % This means that there are two populations to comapare
    display('-----IH Stats All cells in each group -----------------');
    display('  Ih PEAK ------------');
    Ih1 = Ih_stats(Rs{1}, 0.05);
    Ih2 = Ih_stats(Rs{2}, 0.05);
    Ttest(Ih1.Ih_peak, Ih2.Ih_peak);
    display('  Ih SSTATEV ------------');
    Ttest(Ih1.Ih_sstateV, Ih2.Ih_sstateV);
    
    display(' ');
    display('--------------IH Stats - WITHIN CELL POPULATIONS  -----------------');
    for i=1:numel(Rs)
        display(sprintf('%s SMALLER (X1) vs BIGGER (X2)', upper(pop_names{i})));
        display('  Ih PEAK ------------');
        Ihb = Ih_stats(b{i}, 0.05);
        Ihs = Ih_stats(sm{i}, 0.05);
        Ttest(Ihs.Ih_peak, Ihb.Ih_peak);
     
        display('  Ih SSTAEV ------------');
        Ihb = Ih_stats(b{i}, 0.05);
        Ihs = Ih_stats(sm{i}, 0.05);
        Ttest(Ihs.Ih_sstateV, Ihb.Ih_sstateV);
        
        display(' ');
    end
    
    display('--------------IH Stats - BETWEEN CELL POPULATIONS  -----------------');
 
    display(sprintf('-----%s vs. %s', upper(pop_names{1}), upper(pop_names{2})));
 
    display('  SMALLER Ih PEAK ------------');
    Ih1 = Ih_stats(sm{1}, 0.05);
    Ih2 = Ih_stats(sm{2}, 0.05);
    Ttest(Ih1.Ih_peak, Ih2.Ih_peak);
    
    display('  SMALLER Ih SSTAEV ------------');
    Ttest(Ih1.Ih_sstateV, Ih2.Ih_sstateV);
    
    display(' ');    
    display('  BIGGER Ih PEAK ------------');
    Ih1 = Ih_stats(b{1}, 0.05);
    Ih2 = Ih_stats(b{2}, 0.05);
    Ttest(Ih1.Ih_peak, Ih2.Ih_peak);
    
    display('  SMALLER Ih SSTATEV ------------');
    Ttest(Ih1.Ih_sstateV, Ih2.Ih_sstateV); 
end


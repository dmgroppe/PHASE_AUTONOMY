function [] = tf_stats(cond1, cond2, frq, params)

frq_ranges = franges();

[nfreq, npoints, nsubjects] = size(cond1);

labels1.x = 'Time (ms)';
labels1.y = 'Freq (Hz)';
labels1.title = 'Normalized power';
labels1.z.max = 3;
labels1.z.min = 0;
    
labels2 = labels1;  
labels2.z.max = 3;
labels2.z.min = 0;
labels2.title = 'Normalized Power';

bl_samples = time_to_samples(params.ana.baseline, params.data.srate);
bwidthsamples = time_to_samples(params.stats.tbin_width, params.data.srate);


for i=1:length(franges)
    fstart = get_index(frq, frq_ranges(i).lb);
    fend = get_index(frq, frq_ranges(i).ub);
    b1 = cond1(fstart:fend,(bl_samples+1):end,:);
    b2 = cond2(fstart:fend,(bl_samples+1):end,:);
       
    % Average over the first dimension which is the frequency
    mb1 = mean(b1, 1);
    mb2 = mean(b2, 1);
    
    m1 = reshape(mean(mb1,3),1,(npoints-bl_samples));
    m2 = reshape(mean(mb2,3),1,(npoints-bl_samples));
    %figure(20);
    %plot(1:(npoints-bl_samples), m1, 1:(npoints-bl_samples), m2);
    
    %  Bin the time series for this frequency band
    for j=1:nsubjects
        binned1(:,:,j) = bin_time_series(mb1(:,:,j), bwidthsamples);
        binned2(:,:,j) = bin_time_series(mb2(:,:,j), bwidthsamples);
    end
    %figure(20);
    nbins = size(binned1,2);
    b1 = reshape(binned1,nbins, nsubjects)';
    b2 = reshape(binned2,nbins,nsubjects)';
    
    % Combine the time bins and conditions for permutation ANOVA
    for j=1:nsubjects
        index = (j-1)*nbins+1;
        M(index:j*nbins) = b1(j,:);
    end
    for j=(nsubjects+1):2*nsubjects
        index = (j-1)*nbins+1;
        M(index:j*nbins) = b2(j-nsubjects,:);
    end
    
    [test,prob,thresh] = perm_anova(M', nsubjects, nbins, 2, 1000, .05);
    result = sprintf('%s (%3.1f-%3.1f): p = %6.2f', frq_ranges(i).Name, frq(fstart), frq(fend), prob);

    dplot = [mean(b1);mean(b2)]';
    errors = [std(b1); std(b2)]'/sqrt(nsubjects);

    subplot(length(franges), 1, i);
    barweb(dplot, errors);
    %bar(dplot', 'group');
    title(result, 'fontsize', 8);
    xlabel('Time bin', 'fontsize', 8);
    ylabel('Norm to BL','fontsize', 8);
   
    %anova_rm({b1 b2});
    %O = teg_repeated_measures_ANOVA(M, [2 6],[])
end


function [] = plot_result(x, y, s1, s2, labels1, labels2)

ax(1) = subplot(2,1,1);
generic_tf_plot(x, y, s1, labels1);
    
ax(2) = subplot(2,1,2);
generic_tf_plot(x, y, s2, labels2);
linkaxes(ax, 'xy');




function [] = single_cond_atten_stats(alpha, nfig, aparams)
% aparams1.ana.cond = 'scene';  % Can be face or scene
% aparams1.ana.test_index = [1 2];
% 
% aparams2.ana.subjectname = 'Bonner';
% aparams2.ana.test = 'passive';
% aparams2.ana.cond = 'scene';  % Can be face or scene
% aparams2.ana.test_index = [1 2];
% 
% aparams1.ana.normtobl = 1;

R1 = atten_collapse_condition(aparams);
if (isempty(R1))
    return;
end

switch aparams.ana.atten_sc_bl
    case 'within_test'
        baselines = get_all_atten_baselines(aparams.ana.atten_channel, aparams.ana.test);
    case 'within_cond'
        baselines = get_all_atten_baselines(aparams.ana.atten_channel, aparams.ana.test, aparams.ana.cond);
    otherwise
        baselines = get_all_atten_baselines(aparams.ana.atten_channel);
end
    

% POWER stats
show_stats(R1, baselines, 'power', aparams, alpha, nfig);
% CVAR stats
%show_stats(R1, baselines, 'cvar', aparams, alpha, nfig+1);
%show_stats(R1, baselines, 'plstats', aparams, alpha, nfig+1);


function [] = show_stats(R1, baselines, atype, aparams, alpha, nfig)

dparams = R1.param_list{1};
frq = R1.frq;
npoints = size(R1.spectra, 2);
x = get_x(npoints, dparams.data.srate) - dparams.ana.baseline;

display(sprintf('Computing %s stats...', upper(atype)));

% Average over all the baselines
avg_bl = mean(transform_spectra(baselines, atype),2);

switch atype
    case 'cvar'
        % Do not normalize CVAR data
        p1 = 1-transform_spectra(R1.spectra, atype);
    case 'power'
        p1 = transform_spectra(R1.spectra, atype)./repmat(avg_bl,1,npoints);
    case 'plstats'
        p1 = transform_spectra(R1.spectra, atype);
end


h = figure(nfig);
clf(h);
name = sprintf('%s %s-%s %s: alpha = %6.4f', aparams.ana.subjectname,...
    aparams.ana.test, aparams.ana.cond, upper(atype), alpha);
set(h, 'Name', name);

labels.x = 'Time (ms)';
labels.y = 'Freq (Hz)';

switch atype
    case 'cvar'
        labels.z.min = 0;
        labels.z.max = 0.7;
    case 'plstats'
        labels.z.min = 0;
        labels.z.max = 0.1;
    otherwise
        labels.z.min = 0.5;
        labels.z.max = 2.0;
end

% Compute P value and plot it
[praw_inc praw_dec] = single_cond_bootstrap(R1.spectra, baselines, atype, aparams);

% Correct per Bonferroni-Holm correction
pinc = correct_pvalue(praw_inc, alpha);
pdec = correct_pvalue(praw_dec, alpha);

if (has_range(pinc) && has_range(pdec))
    nplot = 3;
elseif (has_range(pinc) || has_range(pdec))
    nplot = 2;
else
    nplot = 1;
end

plot_number = 1;
labels.title = sprintf('%s CH%d %s-%s', upper(atype), aparams.ana.atten_channel,...
    aparams.ana.test, aparams.ana.cond);

ax(1) = subplot(nplot,1,plot_number);
generic_tf_plot(x, frq, p1, labels);

if (has_range(pinc))
    plot_number = plot_number+1;
    ax(plot_number) = subplot(nplot,1,plot_number);
    labels.z.min = 0;
    labels.z.max = 1;

    labels.title = sprintf('%s CH%d %s-%s > baseline', upper(atype), aparams.ana.atten_channel,...
        aparams.ana.test, aparams.ana.cond);
    generic_tf_plot(x, frq, pinc, labels);
else
    display('No range for Cond > baseline to display')
end

if (has_range(pdec))
    plot_number = plot_number+1;
    ax(plot_number) = subplot(nplot,1,plot_number);
    labels.z.min = 0;
    labels.z.max = 1;

    labels.title = sprintf('%s CH%d %s-%s < baseline', upper(atype), aparams.ana.atten_channel,...
        aparams.ana.test, aparams.ana.cond);
    generic_tf_plot(x, frq, pdec, labels);
else
    display('No range for Cond < baseline to display')
end

linkaxes(ax, 'xy');

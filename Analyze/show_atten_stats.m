function [] = show_atten_stats(st)

dparams = st.R1.param_list{1};
frq = st.R1.frq;
npoints = size(st.R1.spectra, 2);

display(sprintf('Computing %s stats...', upper(st.atype)));
blsamples = time_to_samples(dparams.ana.baseline, dparams.data.srate);
x = get_x(npoints, dparams.data.srate) - dparams.ana.baseline;

[~,r1, r2] = get_z(st.R1.spectra, st.R2.spectra, st.norm, st.atype, blsamples);

if (strcmp(st.atype, 'power'))
    % This speeds things up a bit by precomputing POWER
    s1 = abs(st.R1.spectra).^2;
    s2 = abs(st.R2.spectra).^2;
else
    s1 = st.R1.spectra;
    s2 = st.R2.spectra;
end

% Display the raw data
h = figure(st.nfig);
clf(h);

name = sprintf('%s %s-%s vs %s-%s %s: alpha = %6.4f', st.aparams1.ana.subjectname, st.aparams1.ana.test,...
    st.aparams1.ana.cond, st.aparams2.ana.test, st.aparams2.ana.cond, upper(st.atype), st.alpha);
set(h, 'Name', name);

labels.x = 'Time (ms)';
labels.y = 'Freq (Hz)';

switch st.norm
    case ''
        labels.z.max = max([max(max(r1)) max(max(r2))]);
        labels.z.min = min([min(min(r2)) min(min(r2))]);
    otherwise
        switch st.atype
            case 'cvar'
                r1 = norm_to_bl(1-r1, blsamples);
                r2 = norm_to_bl(1-r2, blsamples);
                labels.z.min = 0;
                labels.z.max = 5;
            otherwise
                r1 = norm_to_bl(r1, blsamples);
                r2 = norm_to_bl(r2, blsamples);
                labels.z.min = 0.5;
                labels.z.max = 2;
        end
end
            
labels.title = sprintf('%s CH%d %s-%s', upper(st.atype), st.aparams1.ana.atten_channel,...
    st.aparams1.ana.test, st.aparams1.ana.cond);

ax(1) = subplot(3,1,1);
generic_tf_plot(x, frq, r1, labels);

ax(2) = subplot(3,1,2);
labels.title = sprintf('%s CH%d %s-%s', upper(st.atype), st.aparams2.ana.atten_channel,...
    st.aparams2.ana.test, st.aparams2.ana.cond);
generic_tf_plot(x, frq, r2, labels);

% Do stats and display them
praw = par_two_sided_perm(s1, s2, st.atype, st.aparams1, dparams);
[p, actp] = correct_pvalue(praw, st.alpha);

ax(3) = subplot(3,1,3);
labels.title = sprintf('cond1 > cond2: P-value');
labels.z.max = max(max(p));
labels.z.min = 0;

if (max(max(p)) ~= min(min(p)))
    generic_tf_plot(x, frq, p, labels);
    plot_actp(actp, frq, st, st.nfig+1);
else
    sprintf('%s-%s > %s-%s: No range for %s p-values to plot - alpha = %6.4f', st.aparams1.ana.test, ...
        st.aparams1.ana.cond, st.aparams2.ana.test, st.aparams2.ana.cond, upper(st.atype), st.alpha);
end

linkaxes(ax, 'xy');

function [] = plot_actp(actp, frq, st, nfig)
h = figure(nfig);
set(h, 'Name', 'Actual P-value');
plot(frq, actp);
set(gcf,'Color','w');
axis([frq(1) frq(end) 0 st.alpha]);
xlabel('Frquency (Hz)');
ylabel('P-value');


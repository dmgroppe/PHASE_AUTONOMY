function [R, h] = spec_stats(sm, cfg, doplot)

% Function to take the spec_means results and summarize the number of
% channels displaying significant increases in power and precursor values.
% 'sm' is the spec_means data structure.

% Return handles to figure in h
% Return results in R

if nargin < 3; doplot = 0; end;

h = [];

nsig_p_freq_inc = 0;
nsig_p_freq_dec = 0;

nsig_p_chan = 0;
sig_p_chan = [];
sig_f_chan = [];

nsig_f_freq_inc = 0;
nsig_f_freq_dec = 0;
nsig_f_chan = 0;

no_onset = 0;
no_onset_chan = [];

onset = 0;
onset_chan = [];

for i=1:sm.nchan
    % Count the number of times a frequency was significant (total count
    % would be nchan if the frequency was significant in every channel.
    % Do for both power, and frequency velocity
    
    if ~isempty(sm.P_sig{i})
        nsig_p_freq_inc = nsig_p_freq_inc + sm.P_sig{i}'.*(sign(sm.P_mean{i}(:,2) -  sm.P_mean{i}(:,1)) == 1);
        nsig_p_freq_dec = nsig_p_freq_dec + sm.P_sig{i}'.*(sign(sm.P_mean{i}(:,2) -  sm.P_mean{i}(:,1)) == -1);
    end
    
    if ~isempty(sm.F_sig{i})
        nsig_f_freq_inc = nsig_f_freq_inc + sm.F_sig{i}'.*(sign(sm.F_mean{i}(:,2) -  sm.F_mean{i}(:,1)) == 1);
        nsig_f_freq_dec = nsig_f_freq_dec + sm.F_sig{i}'.*(sign(sm.F_mean{i}(:,2) -  sm.F_mean{i}(:,1)) == -1);
    end
    
    % Count the number of channels that do not have an onset.  Do this by
    % counting how many do not have a mean power value
    
    if isempty(sm.P_mean{i})
        no_onset = no_onset + 1;
        no_onset_chan(no_onset) = i;
    else
        onset = onset + 1;
        onset_chan(onset) = i;
    end
    
    
    % Count the number of channels that have significant power and F changes
    if ~isempty(sm.P_sig{i})
        if sum(sm.P_sig{i});
            nsig_p_chan = nsig_p_chan + 1;
            sig_p_chan(nsig_p_chan) = i;
        end
    end
    
    if ~isempty(sm.F_sig{i})
        if sum(sm.F_sig{i});
            nsig_f_chan = nsig_f_chan + 1;
            sig_f_chan(nsig_f_chan) = i;
        end
    end 
end


% Summarize the key stats
pf_sum(1) = onset/sm.nchan;  
pf_sum(2) = nsig_p_chan/sm.nchan;
pf_sum(3) = nsig_f_chan/sm.nchan;

n_p_and_f = numel(intersect(sig_p_chan, sig_f_chan));
pf_sum(4) =  n_p_and_f/nsig_f_chan;
pf_sum(5) = n_p_and_f/nsig_p_chan;

% Save the results
    R = struct_from_list('nsig_p_freq_inc', nsig_p_freq_inc, 'nsig_p_freq_dec', nsig_p_freq_dec, ...
        'nsig_f_freq_inc', nsig_f_freq_inc, 'nsig_f_freq_dec', nsig_f_freq_dec, 'nsig_p_chan', ...
        nsig_p_chan, 'sig_p_chan', sig_p_chan, 'nsig_f_chan', nsig_f_chan, 'sig_f_chan', sig_f_chan,...
        'no_onset', no_onset, 'no_onset_chan', no_onset_chan, 'onset', onset, 'onset_chan', onset_chan, 'pf_sum', pf_sum);

% Plot the results
    
if doplot
    % Plot the histograms of significant increases and decreases

    % Power
    h(1) = figure; clf;
    ax = [];
    if ~ isempty(nsig_p_freq_inc) && nsig_p_chan
        ax(1) = subplot(2,1,1);
        plot_nsig_histogram(cfg.stats.ph_tf_freqs, nsig_p_freq_inc/nsig_p_chan)
        xlabel('Frequency Hz');
        ylabel('Fraction sig channel');
        title('Significant power increases');
    end

    if ~ isempty(nsig_p_freq_dec) && nsig_p_chan
        ax(2) = subplot(2,1,2);
        plot_nsig_histogram(cfg.stats.ph_tf_freqs, nsig_p_freq_dec/nsig_p_chan);
        xlabel('Frequency Hz');
        ylabel('Fraction sig channel');
        title('Significant power decreases');
    end
    if ~isempty(ax)
        linkaxes(ax, 'xy');
    end


    % Plot the histograms of significant FV increases and decreases
    h(2) = figure; clf;
    ax = [];

    if ~ isempty(nsig_f_freq_inc) && nsig_f_chan
        ax(1) = subplot(2,1,1);
        plot_nsig_histogram(cfg.freqs, nsig_f_freq_inc/nsig_f_chan)
        xlabel('Frequency Hz');
        ylabel('Fraction sig channel');
        title('Significant FV increases');
        axis([1 cfg.freqs(end) ylim]);
    end

    if ~ isempty(nsig_p_freq_dec) && nsig_p_chan
        ax(2) = subplot(2,1,2);
        plot_nsig_histogram(cfg.freqs, nsig_f_freq_dec/nsig_f_chan);
        xlabel('Frequency Hz');
        ylabel('Fraction sig channel');
        title('Significant FVdecreases');
        axis([1 cfg.freqs(end) ylim]);
    end
    if ~isempty(ax)
        linkaxes(ax, 'xy');
    end

    
    display(' ');
    display('------------- Spec_stats summary ----------------');
    display(sprintf('Total number of channels = %d', sm.nchan));
    display(sprintf('Of these %d (%4.2f percent)displayed onsets.', onset, pf_sum(1)*100));
    display(sprintf('Of those with onsets %d (%4.2f percent) had significant POWER change', nsig_p_chan, pf_sum(2)*100));
    display(sprintf('Of those with onsets %d (%4.2f percent) had significant FV change', nsig_f_chan, pf_sum(3)*100));

    n_p_and_f = numel(intersect(sig_p_chan, sig_f_chan));
    display(sprintf('%d (%4.2f percent) channels with FA    increase had POWER increases', n_p_and_f, pf_sum(4)*100));
    display(sprintf('%d (%4.2f percent) channels with POWER increase had FA increases', n_p_and_f, pf_sum(5)*100));
end


function [] = plot_nsig_histogram(xval, yval)
bar(xval, yval);
axis([0 xval(end) ylim]);


set(gca, 'TickDir', 'out', 'FontName', 'Times New Roman');
xlabel('Frequency Hz');
ylabel('Fraction sig channel');
title('Significant power increases');




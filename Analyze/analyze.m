function [R] = analyze(params)

if (~check_ana_params(params))
    return;
end

load([params.ana.dataDir params.ana.dataFile]);
tags = load_tags([params.ana.dataDir params.ana.tagFile]);

if (isempty(tags))
    display('Error loading tags.');
    return;
end

if (params.trig.get_from_file)
    trig_dur = time_to_samples(params.trig.min_trig_dur, EEG.srate);
    epochs = find_epochs(EEG.data(EEG.nbchan,:), params.trig.dir,...
    params.trig.offset, params.trig.baseline, params.trig.threshold,...
    trig_dur, params.trig.plot);
    %epochs
    tags = update_tags(tags, epochs, params, EEG.srate);
    %if (~continue_prompt())
    %    display('Aborting.');
    %    return
    %end
end

if (params.debug.show)
    tags{:}
end


if (isempty(tags))
    display('Error converting tags.');
    return;
end

params.data.srate = EEG.srate;
display_data_summary(EEG, tags);
display(' ');
display('Starting analysis:');

channel_n = length(params.ana.chlist);

for i=1:channel_n
    channel = params.ana.chlist(i);
    ch_tags = get_ch_tags(tags, channel);
    if (i ==1 )
        display(sprintf('Total number of epochs: %d', length(ch_tags)));
    end
    display(sprintf('Channel #%d', params.ana.chlist(i)));
    
    % Initialize some fo the counters and matricies
    nepochs = length(params.ana.epoch_list);
    total_epochs_analzed = 0;
    spectra = [];
    params.ana.epochs_analyzed = [];
    alimit_list = {};
    for j=1:nepochs
        include = 1;
        epoch_n = params.ana.epoch_list(j);
        epoch_tag = get_epoch_tag(ch_tags,epoch_n);
        if (isempty(epoch_tag))
            display('Channel list and external tag file incompatability');
            return;
        end
        %display(sprintf('Epoch#%d: %6.0fms to %6.0fms', epoch_n, epoch_tag.limits(1), epoch_tag.limits(2)));
        if (epoch_tag.valid )
            display(sprintf('Epoch %d is valid.', epoch_n));
            if (epoch_tag.markers(1))
                display(sprintf('  Marked at %5.0f ms', epoch_tag.markers(1)));
                if (params.ana.exlude_marked)
                    include = 0;
                end
                % If doing fixed length analysis, the marker can not be
                % within the fixed length region
                if (params.ana.fixed_length)
                    if (epoch_tag.markers(1) < params.ana.length)
                        include = 0;
                        display('  Marker within fixed length region')
                    end
                end
            end
        else
            display(sprintf('Epoch %d is NOT valid', epoch_n));
            if (params.ana.exclude_invalid)
                include = 0;
            end
        end
        if (include)
            total_epochs_analzed = total_epochs_analzed + 1;
            params.ana.epochs_analyzed(total_epochs_analzed) = epoch_n;
            alimit = get_analysis_limits(epoch_tag, params, EEG.srate, EEG.pnts);
            alimit_list{total_epochs_analzed} = alimit;
            if (params.debug.show)
                alimit
            end
            
            % Get the epoch from the EEG
            epoch = EEG.data(channel, (alimit.ep_start-alimit.prefix):(alimit.ep_end+alimit.suffix));
                       
            % Compute some indicies for getting data etc.
            base_line_samples = time_to_samples(params.ana.baseline, EEG.srate);
            dstart = alimit.prefix - base_line_samples;
            dend = alimit.prefix+(alimit.ep_end-alimit.ep_start)-1;
            
             % Added for export, each epoch (without padding)
            data(total_epochs_analzed,:) = epoch(dstart:dend);
            % Epoch_ts contains the epochs padded with additonal samples 
            padded_data(total_epochs_analzed,:) = epoch;
            
            % zero mean the data
            epoch = epoch-mean(epoch);
            
            % For surrogates - going to take this out
            if (params.tf.scramble_phase)
                epoch = scramble_phase(epoch);
            end
            
            [wt frq] = twt(epoch, EEG.srate, get_scales(params, EEG.srate), params.wlt.bw);
            if (params.ana.fixed_length)
                % adjust the beginning by the number of  base line samples
                spectra(:,:,total_epochs_analzed) = wt(:,dstart:dend);
                %alimit
            else
                % Need to deal here with non-fixed length analyses
            end
     
        else
            display('  This epoch will NOT be included.')
        end
    end
    % All the spectra are now computed - can do all other calculations
    
    % Plot the average power
    h = figure(1);
    set(h, 'Name', upper(sprintf('%s CH%d, TF', params.export.prefix,  channel)));
    plot_tf(spectra, frq, EEG.srate, params);
        
    % Plot the cross-frequency modulation
    
%     h = figure(2);
%     set(h, 'Name', upper(sprintf('%s, CH%d, Modulation', params.export.prefix,  channel)));
%     display('Computing cross-frequency modulation...');
%     blsamples = time_to_samples(params.ana.baseline, EEG.srate);
%     sub_spectra = spectra(:,blsamples:end,:);
%     [mp ms] = cross_freq_mod(sub_spectra);
%     plot_cfmodulation(mp, ms, params, frq);
%     clear('sub_spectra');
    
  
    % If specified compute the PL statistics
    if (params.pl.inclplcalcs)
        display('Computing PL statistics...');
        pl = pl_matrix(length(frq), length(spectra),params.pl.bins);
        for p=1:total_epochs_analzed
            pl = set_pl_matrix(pl, spectra(:,:,p));
        end
        pl_stats = get_pl_stats(pl, params.pl.probbins, params.pl.steps);
        
        % Remove this object, since it is very large
        clear('pl');
                
        h = figure(3);
        set(h, 'Name', 'PL statistics (normalized)');
        plot_spectrum(pl_stats, frq, EEG.srate, params);
        
        
    end

    % Export the results
    params.ana.ch_analyzed = channel;
    params.ana.epochs_analyzed = total_epochs_analzed;
    if (params.export.export_results)
        fn = sprintf('%s%s CH%d.mat', params.export.dir, params.export.prefix, channel);
        display(sprintf('Exporting to %s', fn));
        if (params.pl.inclplcalcs)
            save(fn, 'spectra', 'pl_stats', 'params', 'frq', 'alimit_list');
        else
            save(fn, 'spectra', 'params', 'frq', 'alimit_list');
        end
    else
        display('Export not selected.');
    end
    
    % Ensure an export parameter is passed, and if so set its values
    if (nargout == 1)
        R(i).data = data;
        R(i).padded_data = padded_data;
        R(i).spectra = spectra;
        R(i).alimit_list = alimit_list;
        R(i).params = params;
        R(i).frq = frq;
        if (params.pl.inclplcalcs)
            R(i).pl_stats = pl_stats;
        end
    end
    

    if ( params.debug.prompts) 
        if (~continue_prompt())
            display('Aborting.');
            return
        end
    end
end
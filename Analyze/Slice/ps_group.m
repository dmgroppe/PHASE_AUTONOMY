function [] = ps_group(dap, ftext, dosave, bl_cond)


if nargin < 4; bl_cond = []; end;
if nargin < 3; dosave = 0; end;
if nargin < 2; ftext = ''; end;

ap =sl_sync_params();
rcount = 0;

conds = {};
% Get all the unique conditions
for i=1:numel(dap)
    conds = [conds dap(i).cond.names];
end

uconds = unique(conds);

% Get the user specified base_line
if ~isempty(bl_cond)
    blindex = find_text(uconds,bl_cond);
    if isempty(blindex)
        blindex = 1;
        display('Warning: user specified baseline does not exist');
        display('Using first condition as basline');
    end
else
    blindex = 1;
end

% Get the power spectra

parfor i=1:numel(dap)
    inc = get_sf_val(dap(i), 'GroupInc');
    if strcmp(inc, 'yes') || isempty(inc)
        [~, path_okay] = check_files(dap(i), '.abf');
        if path_okay
            rcount = rcount + 1;
            display(sprintf('Analyzing record %d', i));
            [R(i).w, R(i).ps, R(i).pxx] = ps_slice(dap(i), 0, 0);
        end
    else
        R(i).w = [];
        R(i).ps = [];
        R(i).pxx = [];
    end
end


display(sprintf('Analyzed %d of %d records.', rcount, numel(dap)));

% Normalize each slices individually to the specified baseline condition

for i=1:numel(R)  
    if ~isempty(R(i).w)
        % Normalize the average spectra by the baseline
        w = R(i).w;
        nspectra = size(R(i).ps,2);
        norm = repmat(squeeze(R(i).ps(:,blindex)), 1, nspectra);
        nR(i).ps = R(i).ps./norm;

        % Normalize the individual spectra. Loop over each
        % condition
        for k = 1:numel(R(i).pxx)
            nspectra = size(R(i).pxx{k},1);
            norm = repmat(squeeze(R(i).ps(:,blindex)), 1, nspectra)';
            nR(i).pxx{k} = R(i).pxx{k}./norm;
        end
    end
end

% Modify the freq axis given over_sampling etc

[faxis fend] = faxis_truncate(w, ap);

% Collect all the power spectra for each condition
for i=1:numel(uconds)
    ps = [];
    nps = [];
    pxx = [];
    npxx = [];
    for j=1:numel(dap)
        cindex = find_text(dap(j).cond.names,uconds{i});
        if cindex
            inc = get_sf_val(dap(j), 'GroupInc');
            if strcmp(inc, 'yes');
                ps = [ps R(j).ps(:,cindex)];
                pxx = [pxx R(j).pxx{cindex}'];
                
                nbl_ps = [nps nR(j).ps(:,cindex)];
                nbl_pxx = [npxx nR(j).pxx{cindex}']; 
            end
        end
    end
    
    if ~isempty(ps) && ~isempty(pxx)
        condps{i} = ps;
        condpxx{i} = pxx;
        
        nbl_condps{i} = nbl_ps;
        nbl_condpxx{i} = nbl_pxx;
    else
        display('Empty matrix while collecting condition spectra');
        display('Exiting');
        return;
    end
end

% Compute the average normalized spectra.  This normalization takes all the
% baselines and averages them, then normalizes the individual conditons to
% this 'grand' average baseline


% Get the baseline condition
bline = mean(condps{blindex},2);
ncount = 0;
for i=1:numel(uconds)
    if i ~= blindex
        ncount = ncount + 1;
        avgps(:,ncount) = mean(condps{i},2);
        nps(:,ncount) = mean(condps{i},2)./bline;
        nbl_nps(:,ncount) = mean(nbl_condps{i},2);
        
        ltext{ncount} = sprintf('%s/%s', uconds{i},uconds{blindex});
    end
end

for i=1:numel(uconds)
    [~,nspectra] = size(condpxx{i});
    norm = repmat(bline,1, nspectra);
    ncondpxx{i} = condpxx{i}./norm;
end


%% Do the stats


[sig, sltext, count] = do_stats(uconds,condpxx, ap, faxis);
[nbl_sig, ~, ~] = do_stats(uconds,nbl_condpxx, ap, faxis);


%% Plot the averaged spectra for each condition

h = figure(1);
fig_name = sprintf('PS Group - condition spectra - %s', ftext);
set(h,'Name', fig_name);
loglog(faxis,[bline(1:fend) avgps(1:fend,:)]);
axis square;

if ~isempty(ap.ps.group.yaxis)
    nyaxis = ap.ps.group.yaxis;
else
    nyaxis = [md_min([bline(1:fend) nps(1:fend,:)]) md_max([bline(1:fend) nps(1:fend,:)])];
end
axis([faxis(1) faxis(end) nyaxis]);
legend(uconds);
xlabel('Frequency (Hz)');
ylabel('Power (mV^2/Hz)');
set(gca,ap.pl.axprop, ap.pl.axpropval);
set(gca, ap.pl.textprop, ap.pl.textpropval);
title(sprintf('%s - Individual spectra', ftext));

if dosave
    save_figure(h,export_dir_get(ap),fig_name);
end

%% Plot the normalized spectra and the statistics

h = figure(2);
fig_name  = sprintf('PS Group - %s', ftext);
set(h,'Name', fig_name);
plot_spectra_stats(nps, sig, ap, ftext, uconds, faxis, fend, ltext, sltext, count);

if dosave
    save_figure(h,export_dir_get(ap),fig_name);
end


h = figure(3);
fig_name  = sprintf('PS Group NBL - %s', ftext);
set(h,'Name', fig_name);
plot_spectra_stats(nbl_nps, nbl_sig, ap, ftext, uconds, faxis, fend, ltext, sltext, count);

if dosave
    save_figure(h,export_dir_get(ap),fig_name);
end

function [sig, sltext, count] = do_stats(uconds,condpxx, ap, faxis)
%% Do the stats
count = 0;
nuconds = numel(uconds);

% Correct the alpha for multiple comparisons.  With the FDR correction this
% all turns out to be pretty strict 
alpha = ap.alpha/(nuconds*(nuconds-1)/2);

% Loop over the condition combinations and get p-values
for i=1:nuconds
    for j=i+1:nuconds
        count = count + 1;
        sltext{count} = sprintf('%s v %s', uconds{j},uconds{i});
        for k=1:numel(faxis)
            x1 = condpxx{i}(k,:);
            x2 = condpxx{j}(k,:);
            p(k) = ranksum(x1,x2);
        end
        [~, sig(:,count)] = sig_to_ranges(fdr_vector(p, alpha, ap.fdr_stringent),faxis,ap.minr);
        sig(:,count) = sig(:,count)*count;
    end
end


function [] = plot_spectra_stats(nps, sig, ap, ftext, uconds, faxis, fend, ltext, sltext, count) 
%% Plot the normalized spectra and the statistics
ax(1) = subplot(2,1,1);
loglog(faxis,nps(1:fend, :));
axis square;
set(gca,ap.pl.axprop, ap.pl.axpropval);
set(gca, ap.pl.textprop, ap.pl.textpropval);



if ~isempty(ap.ps.group.normyaxis)
    nyaxis = ap.ps.group.normyaxis;
else
    nyaxis = [md_min(nps(1:fend,:)) md_max(nps(1:fend,:))];
end
axis([faxis(1) faxis(end) nyaxis]);
xlabel('Frequency (Hz)');
ylabel(sprintf('Normalized PS to %s', uconds{1}));
legend(ltext);
title('Normalized power spectra');
axis square;
set(gca,ap.pl.axprop, ap.pl.axpropval);
set(gca, ap.pl.textprop, ap.pl.textpropval);

ax(2) = subplot(2,1,2);
semilogx(faxis,sig(1:fend,:));
axis([faxis(1) faxis(end) 0 count]);
legend(sltext);
xlabel('Frequency (Hz)');
ylabel('Significance');
title('Significance');
axis square;
set(gca,ap.pl.axprop, ap.pl.axpropval);
set(gca, ap.pl.textprop, ap.pl.textpropval);

linkaxes(ax, 'x');




function [R] = pdmi_slice(data_ap, dosave)

% Function to compute power spectra from regions of an ABF file
% specified by the user.  Any number of regions can be specified in the 'ap'
% parameter structure.  Each region must have an associated label with it.


% Set some defaults

ap = sl_sync_params();

if nargin < 2; dosave = 0; end;

% Make sure it all the files exist
[fpaths, path_okay] = check_files(data_ap, '.abf');

if ~path_okay
    display(sprintf('Exiting %s.', mfilename()));
    return;
end

% Loop over the conditons and compute the PS.  The conditons may be
% different lengths

% Get the number of conditions
ncond = numel(data_ap.cond.names);

for i=1:ncond
    [S, from_mat] = abf_load(fpaths{i},data_ap.cond.fname{i}, ap.srate, 0, 'e', 1, ap);
    h = figure(i);clf;
    R{i} = sl_pdmi(S.data, data_ap.cond.times(:,i), ap.srate,  data_ap.chlabels(1:2), false);
    R{i}.cond = data_ap.cond.names{i};
    fname = sprintf('%s - PDMI %s', upper(data_ap.cond.fname{i}), data_ap.cond.names{i});
    set(h, 'Name', fname);
    if dosave
        save_figure(h,export_dir_get(data_ap), fname, false);
    end
end
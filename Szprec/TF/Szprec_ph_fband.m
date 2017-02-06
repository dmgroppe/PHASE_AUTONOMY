function [] = Szprec_ph_fband(sz_name, a_cfg)

% This function takes ths onset time from the ph analysis of wavelet data,
% and the FBAND analysis to ascertain the time dependent changes in FBAND
% desyncronization

global DATA_PATH;

if nargin < 2;
    a_cfg = cfg_default();
end

% Load the PH summary file for this seizure and the associated FBAND file
pt_name = strtok(sz_name, '_');
ph_file = make_data_path(sz_name, 'ph');

if exist(ph_file, 'file')
    load(ph_file)
else
    display('Unable to load PH summary file.')
    return;
end

fband_file = make_data_path(sz_name, 'fband');

if exist(fband_file, 'file')
    load(fband_file);
    F = F{1};
else
    display('Unable to load FBAND file.')
    return;
end

[bad_ch, ~] = bad_channels_get(pt_name);
for i=1:numel(R.loc)
    if isempty(find(i==bad_ch))
        %[spec, freqs] = get_spectrum(matrix_bi(:,i), a_cfg, Sf);
        corr_fband(matrix_bi(:,i),F,R,Sf);
    end 
end

function [wt,freqs] = get_spectrum(d, cfg, srate)
freqs = cfg.fband(1):cfg.fband(2);
a = linear_scale(freqs, srate);
wt = twt(d,srate,a, 5);

function [] = corr_fband(d,F,R,srate)

[npoints, nchan] = size(F);
















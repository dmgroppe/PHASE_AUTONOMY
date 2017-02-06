function [R] = Szprec_ccm_single_seizure(sz_name, ch_list)

global DATA_DIR

cfg = cfg_default();

pt_name = strtok(sz_name, '_');

dfile = fullfile(DATA_DIR, 'Szprec', pt_name, 'Data', [sz_name '.mat']);
out_dir = fullfile(DATA_DIR, 'Szprec', pt_name, 'Processed\CCM\', sz_name);
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

if ~exist(dfile, 'file')
    display(dfile);
    error('Unable to open data file')
end

load(dfile);


nchan_pairs = size(ch_list,2);
switch cfg.chtype
    case 'bipolar'
        d = matrix_bi;
    case 'monopolar'
        d = matrix_mo;
end      

if min(size(ch_list)) == 1;
    nchan_pairs = 1;
end

tic
for i=1:nchan_pairs
    
     if nchan_pairs  == 1
         chans = ch_list;
     else
        chans = ch_list(:,i);
     end
     chans = sort(chans);
     
     a_data = d(:,chans);
     
     % Do all the specified frequencies
     display('CCM for different frequencies...');
     cfg.ccm.dofreqs = 1;
     ccm_freqs = ccm_run(a_data, Sf, cfg);
     
     % Do the time series
      display('CCM for raw time series...');
     cfg.ccm.dofreqs = 0;
     ccm_ts = ccm_run(a_data, Sf, cfg);
    
    %  Save all together
    fname = sprintf('%s_ccm_%d_%d.mat', sz_name, chans(1), chans(2));
    fpath = fullfile(out_dir, fname);
    save(fpath, 'ccm_ts', 'ccm_freqs', 'chans', 'sz_name');
end
toc
function [] = rho_tp_avg(sz_name, tstart, tend, bsize)

% Incomplete function get average rho-Tp plot for all channels in an data
% file.  Maybe not that useful.

cfg = cfg_default();

pt_name = strtok(sz_name, '_');
fpath = fullfile(data_path(pt_name), [sz_name '.mat']);

if ~exist(fpath, 'file')
    display(fpath);
    error('File not found');
end

load(fpath);
switch cfg.chtype
    case 'bipolar'
        d = matrix_bi;
    case 'monopolar'
        d = matrix_mo;
end

nchan = size(d, 2);

pstart = fix(tstart*Sf);
pend = fix(tend*Sf);
bpoints = fix(bsize*Sf);

r = tlimits(bpoints,pend-pstart+1,Sf);
r = r+ pstart;

cfg.ccm.Tps = 1:20;
for i=1:nchan
    d(:,i) = z_mat(remove_nans(d(:,i)));
    for j=1:length(r)
        x = d(r(j,1):r(j,2),i);
        rho(:,j) = sproj_Tp(x, cfg.ccm.dim, cfg.ccm.tau, cfg.ccm.Tps, 0);
    end
    
end



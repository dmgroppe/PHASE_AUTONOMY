function [R] = Szprec_ccm(d, srate, cfg)

% Setup the defaults

if ~isfield(cfg.ccm, 'bp_freqs');cfg.ccm.bp_freqs = []; end;
if ~isfield(cfg.ccm, 'win'); cfg.ccm.win = 1; end;
if ~isfield(cfg.ccm, 'poverlap'); cfg.ccm.win = 0; end;
if ~isfield(cfg.ccm, 'doplot'); cfg.ccm.doplot = 0; end;
if ~isfield(cfg.ccm, 'dim'); cfg.ccm.dim = 3; end;
if ~isfield(cfg.ccm, 'tau'); cfg.ccm.tau = 1; end;
if ~isfield(cfg.ccm, 'NSeg'); cfg.ccm.NSeg = 1; end;
if ~isfield(cfg.ccm, 'nsurr'); cfg.ccm.nsurr = 0; end;
if ~isfield(cfg.ccm, 'Tps'); cfg.ccm.Tps = 1:10; end;

% Remove an bad points that might have creeped in from import step
d(:,1)= remove_nans(squeeze(d(:,1)));
d(:,2)= remove_nans(squeeze(d(:,2)));

% Filter if specified
if cfg.ccm.dofreqs
    x = bpfilt(d(:,1),cfg.ccm.bp_freqs,srate);
    y = bpfilt(d(:,2),cfg.ccm.bp_freqs,srate);
else
    x = d(:,1);
    y = d(:,2);
end

%y = circshift(x, 10);

% Normalize and zero mean
x = z_mat(x(:),1);
y = z_mat(y(:),1);

npoints = length(x);
win_points = cfg.ccm.win*srate;
[r, ~] = tlimits(win_points, npoints, srate, cfg.ccm.poverlap);
    

% Run over the segments
doplot = cfg.ccm.doplot;
parfor i=1:length(r)
    if doplot
        display(sprintf('Segment %d of %d', i, length(r)));           
    end
    [rf(:,i) rb(:,i)] = compute_ccm(x,y,r,i,cfg);
end

% Put results in a structure

R.rf = rf;
R.rb = rb;
R.cfg = cfg;
R.d = d;
R.x = x;
R.y = y;
R.srate = srate;


function [xfilt] = bpfilt(x,bp, srate)
b =fir1(1000,bp/srate);
xfilt = filtfilt(b, 1, x);

function [rf rb] = compute_ccm(x,y,r,i,cfg)
X.data = x(r(i,1):r(i,2));
X.FText = 'CH1';

Y.data = y(r(i,1):r(i,2));
Y.FText = 'CH2';
[rf rb] = ccm(X, Y, 'doplot', cfg.ccm.doplot, 'nsurr', cfg.ccm.nsurr,...
            'NSeg', cfg.ccm.NSeg, 'dim', cfg.ccm.dim, 'tau', cfg.ccm.tau, 'Tps', cfg.ccm.Tps);

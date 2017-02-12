% Computes the Convergent Cross Mapping between two signals as described in
% Sugihara 2012 "Detecting Causality in Complex Ecosystems" Science doi:
% 10.1126/science.1227079.
%
%  USAGE: [rf rb p] = ccm(X, Y, 'Option_name',Option_value,...)
%
%  Output:
%   rf: X xmap Y
%   rb: Y xmap X
%   p: if stats are done the p values for different lenghts of the data
%
%  Input:
%   X - Data structure for time series 1
%   Y - Data structure for time series 2
%       Both have fields 'data', and 'FText': data is the time series, and FText
%       is a text label
%
%  Options:
%   dim -   embedding dimension, if not specified it will be computed as
%           per Sugihara 1990
%   tau -   embedding delay
%   Tps -   Time steps to project forecast, used for computing optimal dim
%           and tau
%   nsurr - number of surrogates to use for stats
%   alpha - for determining statistical significance
%   Lsteps- segments lengths (vector) to subdivide data for computing
%           convergence.  Defaults to steps of 10% of the total length, to
%           a max of half the data length.
%   NSeg -  number of times to compute xmap for estimate.  Computes xmap
%           across Lsteps randomly chosen from the x and y
%   dosave- save the plots
%
% Taufik A Valiante 2012


function [rf rb p] = ccm(X, Y, varargin)

% Get the options
[dim, tau, Tps, Lsteps, alpha, nsurr, NSeg, dosave, doplot] = get_args(X, Y, varargin);
x = X.data(:)';
y = Y.data(:)';
pText = [' ' X.FText ' & ' Y.FText];

if doplot
    % Determine if this data is chaotic or just noise
    display('Generating Rho-Tp plot.');
    maxLen = max(Lsteps);
    rho(:,1) = sproj_Tp(x, dim, tau, Tps, false);
    rho(:,2) = sproj_Tp(y, dim, tau, Tps, false);

    h = figure(1);
    clf('reset');
    fname = sprintf(['CCM Rho-Tp plot' pText]);
    set(h, 'Name', fname);
    plot(Tps, rho(:,1), '.-', Tps, rho(:,2), '.-', 'MarkerSize', 10);
    legend({X.FText Y.FText}, 'Location', 'NorthOutside');
    xlabel('Tp');
    ylabel('Rho');
    axis square;
    axis([Tps(1) Tps(end) 0 1]);
    drawnow;
end

if dosave && doplot
    save_figure(h, get_export_path_SMA(), fname);
end

% Do the convergent part of the cross-mapping by iterating over various
% lenghts of the data

% First compute the average cross mapping values
%display('Computing the average cross-mapping values.')
parfor j=1:NSeg
    [rf(:,j) rb(:,j)] = getxmap(x, y, Lsteps, dim, tau, NSeg);
end

rf = squeeze(mean(rf,2));
rb = squeeze(mean(rb,2));

if doplot
    % Plot these results
    fname = ['CCM results' pText];
    h = figure(2);
    set(h, 'Name', fname);
    clf('reset');
    plot(Lsteps, rf, Lsteps, rb);
    axis([0 Lsteps(end) 0 1.1]);
    legend({[X.FText ' xmap ' Y.FText], [Y.FText ' xmap ' X.FText]}, ...
        'Location', 'NorthOutside');
    xlabel('L');
    ylabel('Rho');
    axes_text_style();
    drawnow;
end



if ~nsurr && dosave && doplot
    save_figure(h, get_export_path_SMA(), fname);
end

% Do stats if specified
if nsurr
    display('Generating surrogates...');
    
    parfor i=1:nsurr
        [sx(:,i),~]=IAAFT(x,1,100);
        [sy(:,i),~]=IAAFT(y,1,100);
    end
    
    display('Computing CCMs for surrogates...');
    for i=1:length(Lsteps);
        display(sprintf('Working on segment %d of %d', i, length(Lsteps)));
        xseg = sx(1:Lsteps(i),:);
        yseg = sy(1:Lsteps(i),:);
        parfor j=1:nsurr
            [~, rf_surr(i,j)] = crossmap(xseg(:,j)',yseg(:,j)',dim,tau, false);
            [~, rb_surr(i,j)] = crossmap(yseg(:,j)',xseg(:,j)',dim,tau, false);
        end
    end
    
    rf_count = 0;
    rb_count = 0;
    for i=1:nsurr
        rf_count = rf_count + (rf_surr(:,i) > rf);
        rb_count = rb_count + (rb_surr(:,i) > rb);
    end

    p.rf = (rf_count + 1)/(nsurr + 1);
    p.rb = (rb_count + 1)/(nsurr + 1);

    figure(h);
    fname = ['CCM results with STATS' pText];
    set(h, 'Name', fname);
    hold on;

    for i=1:length(Lsteps)
        if p.rf(i) <= alpha
            plot(Lsteps(i), rf(i), '.b', 'MarkerSize', 15);
        end

        if p.rb(i) <= alpha
            plot(Lsteps(i), rb(i), '.g', 'MarkerSize', 15);
        end
    end

    hold off;
    
    if dosave
        save_figure(h, get_export_path_SMA(), fname);
    end
else
    p = [];
end

function [rf rb] = getxmap(x, y, Lsteps, dim, tau, NSeg)
NPoints = length(x);

for i=1:length(Lsteps);
    if NSeg == 1
        sstart = 1;
        send = Lsteps(i);
    else
        ri = randi(NPoints-Lsteps(i)-1, 1, 1);     
        sstart = ri;
        send = ri+Lsteps(i);
    end
    [~, rf(i)] = crossmap(x(sstart:send),y(sstart:send),dim,tau, false);
    [~, rb(i)] = crossmap(y(sstart:send),x(sstart:send),dim,tau, false);
end



% Get variable argument list
function [dim, tau, Tps, Lsteps, alpha, nsurr, NSeg, dosave, doplot] = get_args(X, Y, varargin)

opt = {'dim', 'tau', 'Tps', 'Lsteps', 'alpha', 'nsurr', 'NSeg', 'dosave', 'doplot'};
data_fnames = {'data', 'FText'};

% % Make sure the list is paired
% try
%     struct(varargin);
% catch
%     error('CCM: Incorrectly formatted option list.');
% end

args = varargin{1};

% Set all the defaults

% Check to see if the data is okay
check_var(X, data_fnames);
check_var(Y, data_fnames);
if (length(X.data) ~= length(Y.data))
    error('Data lengths must be the same for the two time series.');
end

NPoints = length(X.data);
dim = [];
tau = [];
Tps = 1:8;
doplot = false;

%  Lsteps: Defaults to max of half the data length (so that random selection actually generates
%  different segmenets.  Each segment is 10 percent of the total length.
%  The full data set is however used to generate the estimates.

step = fix(0.1*NPoints);
Lsteps = fix(step:step:(NPoints*0.95));

alpha = 0.05;
nsurr = 0;
NSeg = 200;
dosave = true;

% Get the option values

for i=1:2:numel(args)-1
    ind = find_text(opt, args{i});
    if ind
        estring = sprintf('%s = args{%d};', opt{ind}, i+1);
        eval(estring);
    else
        error('Argument %s is not a valid option.', args{i});
    end
end

% Get the optimal embedding dimension and lag if not set
if isempty(dim)
    display('Computing optimal embedding dimension and tau.');
    [~, dim_max1 tau_max1] = sproj_dim(diff(X.data), Tps, 1:2, 1);
    [~, dim_max2 tau_max2] = sproj_dim(diff(Y.data), Tps, 1:2, 1);
    dim = max([dim_max1 dim_max2]);
    if isempty(tau)
        tau = min([tau_max1 tau_max2]);
    end
end

if max(Lsteps) >= NPoints
    error('Max of Lsteps is equal to or greater than the number of points.');
end

function [] = check_var(V, fnames)
fn = fieldnames(V);

if numel(fn) ~= numel(fnames)
    error('Data variables do not contain the approrpiate number of fields.');
end

for i=1:numel(fn)
    if ~find_text(fn, fnames{i})
        error('%s field must exist in data structure.', fn{i});
    end
end
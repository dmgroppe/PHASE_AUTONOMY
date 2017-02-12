function [] = ccm_test(x, y, varargin)

[dim, tau, Tps, Lsteps, alpha, nsurr, dosave] = get_args(varargin);

function [dim, tau, Tps, Lsteps, alpha, nsurr, dosave] = get_args(varargin)

opt = {'dim', 'tau', 'Tps', 'Lsteps', 'alpha', 'nsurr', 'dosave'};

args = varargin{1};

dim = [];
tau = [];
Tps = 1:8;
Lsteps = [];
alpha = 0.05;
nsurr = 200;
dosave = false;

for i=1:2:numel(args)
    ind = find_text(opt, args{i});
    if ~isempty(ind)
        estring = sprintf('%s = args{%d};', opt{ind}, i+1);
        eval(estring);
    end
end


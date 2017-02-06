function [hp, A, U] = page_hinkley(x, v, sm, doplot)

% USAGE: [hp, A, U] = page_hinkley(x, v, sm, doplot)

% CUMSUM algorithm motivated by Bartolomei et al. (2008) Epileptogenicity of brain structures in human
% temporal lobe epilepsy: a quantified study from intracerebral EEG 

% Input:
%   x       -   timeseries
%   v       -   bias parameter
%   sm      -   amount to smooth the cumulative sum before finding extrema
%   doplot  -   plot the calculations
% Output:
%   hp      -   extrema points (min, max)
%   A       -   Amplitude of the detected changes
%   U       -   raw CUMSUM

% Taufik A Valiante (2015)

if nargin < 2; v = var(x)/10; end;
if nargin < 3; sm = 25; end;
if nargin < 4; doplot = 0; end;

hp = [];
A = [];
x = x(:)';

% page-hinkley
U = cumsum(x-cumsum(x)./(1:length(x))-v);
%U = detrend(U);

% smooth the data
U = smooth(U,sm);

% Find maxima and minima
[~ , min_loc] = findpeaks(-U);
[~ , max_loc] = findpeaks(U);

if isempty(min_loc) || isempty(max_loc)
    %display('Insufficient minima or maxima to continue.');
    return;
end


if doplot
    % Plot stuff
    subplot(2,1,1);
    plot(x)

    subplot(2,1,2);
    plot(U);
    hold on;
    plot(min_loc, U(min_loc), '.r', 'LineStyle', 'none');
    plot(max_loc, U(max_loc), '.g', 'LineStyle', 'none');
    hold off;
end

% Loop over pairs of minima, get jumps

c = 0;
for i=1:(length(min_loc)-1)
    ind = find(max_loc > min_loc(i) & max_loc < min_loc(i+1));
    if ~isempty(ind)
        c = c + 1;
        hp(:, c) = [min_loc(i) max_loc(ind(1))];
    end
end

% This might occur if there is no minimum after a peak
if numel(min_loc) <= numel(max_loc)
    c = c+1;
    hp(:,c) = [min_loc(end) max_loc(end)];
end

hp = hp';

if isempty(hp)
    A = [];
else
    A = U(hp(:,2)) - U(hp(:,1));
end


% function [] = min_find(min_loc, max_loc, start)
% 
% for i = start:numel(min_loc)

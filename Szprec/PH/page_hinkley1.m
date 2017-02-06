function [hp, A, U] = page_hinkley1(x, v, sm, lbp, doplot)

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
if nargin < 4; lbp = 0; end;
if nargin < 5; doplot = 0; end;

hp = [];
A = [];
x = x(:)';

% page-hinkley
U = cumsum(x-cumsum(x)./(1:length(x))-v);
%U = detrend(U);

% smooth the data
if sm
    U = smooth(U,sm);
end

% Find maxima and minima
[~ , min_loc] = findpeaks(-U);
[~ , max_loc] = findpeaks(U);

if isempty(min_loc) || isempty(max_loc)
    %display('Insufficient minima or maxima to continue.');
    return;
end


if doplot
    % Plot stuff
    ax(1) = subplot(2,1,1);
    plot(x)

    ax(2) = subplot(2,1,2);
    plot(U);
    hold on;
    plot(min_loc, U(min_loc), '.r', 'LineStyle', 'none');
    plot(max_loc, U(max_loc), '.g', 'LineStyle', 'none');
    hold off;
    linkaxes(ax, 'x');
    
end

% Loop over pairs of minima, get jumps

c = 0;

for i=1:length(max_loc)
    ind = find(min_loc < max_loc(i));
    if ~isempty(ind)
        c = c + 1;
        hp(:, c) = [min_loc(ind(end)) max_loc(i)];
        
        % Look back for a local-global minimum
        if lbp
            if lbp >= length(ind) 
                min_points = ind;
            else
                min_points = ind((end-lbp+1):end);
            end
            % Find global minimum over interval
            [~, min_i] = min(U(min_loc(min_points)));
            min_i = min_loc(min_points(min_i));
            
            % Max sure the new min is less than the last one and the
            % current max
            if U(min_i) < U(max_loc(i)) && U(min_i) < U(hp(1,c))
                hp(:, c) = [min_i max_loc(i)];
            end
        else
            % Step backwards to find local min
            s = ind(end);
            while s >= 2
                if U(min_loc(s-1)) < U(min_loc(s))
                    s = s-1;
                else
                    break;
                end
            end
            if s ~= ind(end)
                hp(:, c) = [min_loc(s) max_loc(i)];
            end
        end
    end
end

if isempty(hp)
    return;
end

u_min_loc = unique(hp(1,:));
for i=1:length(u_min_loc)
    ind = find(u_min_loc(i) == hp(1,:));
    a = abs(U(hp(1,ind)) - U(hp(2,ind)));
    [~, i_max] = max(a);
    hp_list(i) = ind(i_max);
end

hp = hp(:,hp_list)';

% % Set the global max and min
% [~, gmin] = min(U);
% [~, gmax] = max(U);
% hp(:,length(hp)+1) = [gmin gmax];
% hp = hp';

if isempty(hp)
    A = [];
else
    
    A = U(hp(:,2)) - U(hp(:,1));
end


% function [] = min_find(min_loc, max_loc, start)
% 
% for i = start:numel(min_loc)

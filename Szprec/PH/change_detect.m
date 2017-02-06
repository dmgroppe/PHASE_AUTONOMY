function [hp, A, U, p, all_A] = change_detect(x, v, sm, nsurr, lbp, doplot)

% Computes p-values for changes detected by the page-hinkley algorithm.
% This is a very rapid implementation, so not sure if the statsitical test
% is the best, but seems pretty robust.  Could also use a threshold as
% others have done.

if nargin < 6; doplot = 0; end;
if nargin < 5; lbp = 0; end;
if nargin < 4; nsurr = 0; end;

hp = [];
A = [];
U = [];
p = [];
all_A = [];

% Get changes for x
[hp, A, U] = page_hinkley1(x, v, sm, lbp, doplot);

if isempty(A)
    %display('No changes detected.');
    return;
end

if nsurr 
    % Create some surrogates - not sure if this best null hypothesis
    surr = AAFT(x,nsurr);

    % Compute changes with surrogates
    all_A = [];
    for i=1:nsurr
        [hp_surr{i}, A_surr{i}, U_surr{i}] = page_hinkley1(squeeze(surr(:,i))', v, sm, lbp, 0);
        all_A = [all_A' A_surr{i}(:)']';
    end

    % Get p-values
    if ~isempty(all_A)
        for i=1:numel(A)
            p(i) = sum(A(i) < all_A)/numel(all_A);
        end
    end
end
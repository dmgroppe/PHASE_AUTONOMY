function [r, c] = milti_square_plot(np)

% Determines the number of rows and colums to could accomodate 'np' in a
% square arrangement

%np = nchan*(nchan-1)/2;
c = ceil(sqrt(np));
if mod(np,c) == 0
    r = np/c;
else
    r = c;
end

if (r*c - np ) >= r
    r = r-1;
end
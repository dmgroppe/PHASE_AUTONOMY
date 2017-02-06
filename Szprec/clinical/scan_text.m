function [nfind, ind, words] = scan_text(text, delimiters)

% This function finds words that are common to the different
% cells of text. It first strips the delimters from the text cells, adn
% then compares them to see if there any words that are the same.

if nargin < 2
    delimiters = '.,;:-"`';
end

nlines = numel(text);

for i=1:nlines
    s_text{i} = strip_delimters(text{i},delimiters);
    w = textscan(s_text{i},'%s');
    words{i} = w{1};
end

nfind = zeros(1,nlines-1);
for i=1:(nlines-1)
    for j=i+1:nlines
        for w = 1:numel(words{j})
            ind{i}{w} = strfind(s_text{i}, words{j}{w});
            nfind(i) = nfind(i) + numel(ind{i}{w});
        end
    end
end


function [text] = strip_delimters(text, delim)

for i=1:length(delim)
    text(find(text == delim(i))) = ' ';
end
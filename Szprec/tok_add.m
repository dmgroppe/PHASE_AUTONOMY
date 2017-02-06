function [ns] = tok_add(s, tok, new_tok)

parts = textscan(s, '%s', 'delimiter', tok);

ns = [];
for i=1:numel(parts{1})
    ns = [ns parts{1}{i} new_tok];
end